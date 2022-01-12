require 'io/console'

module Grdn
  class CLI
    def initialize
      password = ask_password
      @storage = Storage.new(password)
      execute
    rescue Grdn::Error => e
      STDERR.puts e.message
      exit 1
    end

    def ask_password
      IO::console.getpass 'Password: '
    end

    def execute
      case ARGV.shift
      when 'get'
        cmd_get
      when 'set'
        cmd_set
      when 'list'
        cmd_list
      when 'remove'
        cmd_remove
      else
        raise Grdn::Error.new('Unknown command')
      end
    end

    def cmd_get
      print @storage.get(ARGV)
    end

    def cmd_set
      print 'Seed (paste, then hit enter three times): '
      $/ = "\n\n\n"
      input = STDIN.noecho(&:gets)
      $/ = "\n"
      seed = input.strip.split.join(' ')
      words = seed.split.size
      if words != 12
        STDERR.puts "Invalid seed. That one is #{words} words, must be 12"
        exit 1
      end
      @storage.set(ARGV, seed)
      STDERR.puts 'Seed saved!'
      STDERR.puts "#{seed}"
    end

    def cmd_list
      STDERR.puts "Seeds (leaves are underlined):\n\n"
      print_tree @storage.list
      STDERR.puts
    end

    def cmd_remove
      STDERR.puts "Printing here for safety: #{@storage.get(ARGV)}"
      @storage.remove(ARGV)
      STDERR.puts 'Seed removed!'
    end

    private

    def print_tree(tree, indent = 2)
      tree.sort.to_h.each do |key, value|
        next if key == Storage::FINAL_MARKER

        print ' ' * indent
        puts value[Storage::FINAL_MARKER] ? key.underline : key
        print_tree(value, indent + 2) unless value.empty?
      end
    end
  end
end
