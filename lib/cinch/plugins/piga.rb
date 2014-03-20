require 'cinch'

module Cinch::Plugins
  class Piga

    include Cinch::Plugin

    match /piga/i

    set :help, <<-EOF
!piga
  Explore the pigaverse with this one weird command.
EOF

    def execute(m)
      result = []
      # poorman's weighting, but it does the trick
      letters = %W{a b b b b b b b b b b b b b b b b b b b c c c c c c c d d d e f f f f f g g g h h h h h h h h i j j k l l l l l m m m m m m m n n n n n n n o p p p p p p p q r r r r r r r r s t t t t t t t t t t t t t t u u u u u v w w w x y z}
      while result.length < 1
        letter = letters[rand(0..letters.length-1)]
        result = `grep -i piga#{letter} data/spewfile`.split(/\n/)
      end
      m.reply result[rand(0..result.length-1)]
    end

  end
end