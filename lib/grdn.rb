# frozen_string_literal: true

require_relative "grdn/version"

class String
  def underline
    "\e[4m#{self}\e[24m"
  end
end

module Grdn
  class Error < StandardError; end
  # Your code goes here...
end

require_relative "grdn/storage"
require_relative "grdn/cli"
