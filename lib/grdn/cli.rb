require 'io/console'

module Grdn
  class CLI
    def execute
      if ARGV.size == 0 || ['-h', '--help', 'help'].include?(ARGV[0])
        cmd_help
        exit
      end

      password = ask_password
      @storage = Storage.new(password)

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
    rescue Grdn::Error => e
      STDERR.puts e.message
      exit 1
    end

    def ask_password
      IO::console.getpass 'Password: '
    end

    def cmd_help
      puts <<~HELP
                       Garden: a place for your seeds
                            _
                          _(_)_                          wWWWw   _
              @@@@       (_)@(_)   vVVVv     _     @@@@  (___) _(_)_
             @@()@@ wWWWw  (_)\\    (___)   _(_)_  @@()@@   Y  (_)@(_)
              @@@@  (___)     `|/    Y    (_)@(_)  @@@@   \\|/   (_)\\
               /      Y       \\|    \\|/    /(_)    \\|      |/      |
            \\ |     \\ |/       | / \\ | /  \\|/       |/    \\|      \\|/
            \\\\|//   \\\\|///  \\\\\\|//\\\\\\|/// \\|///  \\\\\\|//  \\\\|//  \\\\\\|// 
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

          This tool stores seed phrases in a local directory (~/.grdn),
          and allows you to organize them hierarchically. Seeds are
          AES-128 encrypted with a password (the same one for all seeds),
          and stored in a tree structure. This allows organization by
          purpose, location, application, wallet, or anything else you
          can think of. They can be nested as deeply as you want. This
          tool is not recommended for security-critical usecases.

        =================================================================

        Usage: grdn <command> [args]

        Commands:
          list                              List your seeds
          set a [b c d e f ...]             Add a seed
          get a [b c d e f ...]             Retrieve a seed
          remove a [b c d e f ...]          Remove a seed

        Example:
          The following commands:
            $ grdn set commerce development my.email+test@domain.com
            $ grdn set commerce production my.email@domain.com
            $ grdn set commerce production my.other.email@domain.com
            $ grdn set phone coinbase-wallet username
            $ grdn set laptop electrum default_wallet
            $ grdn set random

          would product this output:
            $ grdn list

            commerce
              development
                my.email+test@domain.com
              production
                my.email@domain.com
                my.other.email@domain.com
            laptop
              electrum
                default_wallet
            phone
              coinbase-wallet
                username
            random
      HELP
    end

    def cmd_get
      if ARGV.empty?
        STDERR.puts "Path must contain at least one segment"
        exit
      end
      puts @storage.get(ARGV)
    end

    def cmd_set
      if ARGV.empty?
        STDERR.puts "Path must contain at least one segment"
        exit
      end

      print 'Seed (type or paste, then hit enter three times): '
      $/ = "\n\n\n"
      input = STDIN.noecho(&:gets)
      $/ = "\n"
      seed = input.strip.split.join(' ')
      words = seed.split.size
      valid_seed_lengths = [12, 24]
      if !valid_seed_lengths.include? words
        STDERR.puts "Invalid seed. That one is #{words} words, must be " \
                    "#{valid_seed_lengths.join('/')} words"
        exit 1
      end
      @storage.set(ARGV, seed)
      STDERR.puts 'Seed saved!'
      STDERR.puts "#{seed}"
    end

    def cmd_list
      puts
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
