module Amb
  require 'continuation'

  class ExhaustedError < RuntimeError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  # Memoize and return the alternatives associated continuations.
  #
  # @return [Array<Proc, Continuation>]
  #
  def back_amb
    @__back_amb ||= [Proc.new { fail ExhaustedError, "amb tree exhausted" }]
  end

  # Make a choice amoung a set of discrete values.
  #
  # @param choices
  #
  def choose(choices)
    choices.each do |choice|
      callcc do |fk|
        back_amb << fk
        return choice
      end
    end
    failure
  end
  alias :choices :choose
  alias :alternatives :choose

  # Unconditional failure of a constraint, causing the last choice to be
  # retried. This is equivalent to saying `assert(false)`.
  #
  # Use to force a search for another solution (see examples).
  # @TODO it'd be better not to have to
  #
  def failure
    @__num_of_tries ||= 0
    @__num_of_tries += 1
    back_amb.pop.call
  end

  # Assert the given condition is true. If the condition is false,
  # cause a failure and retry the last choice. One may specify the condition
  # either as an argument or as a block. If a block is provided, it will be
  # passed the arguments, whereas without a block, the first argument will
  # be used as the condition.
  #
  # @param cond
  # @yield
  #
  def assert(*args)
    cond = block_given? ? yield(*args) : args.first
    failure unless cond
  end

  def branches_count
    @__num_of_tries
  end

  module ClassMethods
    # Class convenience method to search for the first solution to the
    # constraints.
    #
    def solve
      amb = self.new
      yield(amb)
    rescue Amb::ExhaustedError
    end

    # Class convenience method to search for all the solutions to the
    # constraints.
    #
    def solve_all
      amb = self.new
      yield(amb)
      amb.failure
    rescue Amb::ExhaustedError
    end
  end

  extend self
  extend self::ClassMethods
end
