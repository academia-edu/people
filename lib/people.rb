module People

  EMPTY = "".freeze

  # Class to parse names into their components like first, middle, last, etc.
  class NameParser

    def initialize(opts={})
      @name_chars = "[:alpha:]0-9\\-\\'".freeze
      @nc = @name_chars.freeze

      @opts = {
        :strip_mr   => true,
        :strip_mrs  => false,
        :case_mode  => 'proper',
        :couples    => false
      }.merge!(opts).freeze

      ## constants

      @titles = [ 'Mr\.? and Mrs\.? ',
                  'Mrs\.? ',
                  'M/s\.? ',
                  'Ms\.? ',
                  'Miss\.? ',
                  'Mme\.? ',
                  'Mr\.? ',
                  'Messrs ',
                  'Mister ',
                  'Mast(\.|er)? ',
                  'Ms?gr\.? ',
                  'Sir ',
                  'Lord ',
                  'Lady ',
                  'Madam(e)? ',
                  'Dame ',

                  # Medical
                  'Dr\.? ',
                  'Doctor ',
                  'Sister ',
                  'Matron ',

                  # Legal
                  'Judge ',
                  'Justice ',

                  # Police
                  'Det\.? ',
                  'Insp\.? ',

                  # Military
                  'Brig(adier)? ',
                  'Capt(\.|ain)? ',
                  'Commander ',
                  'Commodore ',
                  'Cdr\.? ',
                  'Colonel ',
                  'Gen(\.|eral)? ',
                  'Field Marshall ',
                  'Fl\.? Off\.? ',
                  'Flight Officer ',
                  'Flt Lt ',
                  'Flight Lieutenant ',
                  'Pte\. ',
                  'Private ',
                  'Sgt\.? ',
                  'Sargent ',
                  'Air Commander ',
                  'Air Commodore ',
                  'Air Marshall ',
                  'Lieutenant Colonel ',
                  'Lt\.? Col\.? ',
                  'Lt\.? Gen\.? ',
                  'Lt\.? Cdr\.? ',
                  'Lieutenant ',
                  '(Lt|Leut|Lieut)\.? ',
                  'Major General ',
                  'Maj\.? Gen\.?',
                  'Major ',
                  'Maj\.? ',

                  # Religious
                  'Rabbi ',
                  'Brother ',
                  'Father ',
                  'Chaplain ',
                  'Pastor ',
                  'Bishop ',
                  'Mother Superior ',
                  'Mother ',
                  'Most Rever[e|a]nd ',
                  'Very Rever[e|a]nd ',
                  'Mt\.? Revd\.? ',
                  'V\.? Revd?\.? ',
                  'Rever[e|a]nd ',
                  'Revd?\.? ',

                  # Other
                  'Prof(\.|essor)? ',
                  'Ald(\.|erman)? '
                ].map { |title| Regexp.new( "^(#{title})(.+)", true ) }.freeze


      suffixes = [
                   'Jn?r\.?,? Esq\.?',
                   'Sn?r\.?,? Esq\.?',
                   'I{1,3},? Esq\.?',

                   'Jn?r\.?,? M\.?D\.?',
                   'Sn?r\.?,? M\.?D\.?',
                   'I{1,3},? M\.?D\.?',

                   'Sn?r\.?',         # Senior
                   'Jn?r\.?',         # Junior

                   'Esq(\.|uire)?',
                   'Esquire.',
                   'Attorney at Law.',
                   'Attorney-at-Law.',

                   'Ph\.?d\.?',
                   'C\.?P\.?A\.?',

                   'XI{1,3}',            # 11th, 12th, 13th
                   'X',                  # 10th
                   'IV',                 # 4th
                   'VI{1,3}',            # 6th, 7th, 8th
                   'V',                  # 5th
                   'IX',                 # 9th
                   'I{1,3}\.?',             # 1st, 2nd, 3rd
                   'M\.?D\.?',           # M.D.
                   'D.?M\.?D\.?'         # M.D.
                  ]
      @suffixes_commaized = suffixes.map { |sfx| Regexp.new( "(.+), (#{sfx})$", true ) }.freeze
      @suffixes_nocomma = suffixes.map { |sfx| Regexp.new( "(.+) (#{sfx})$", true ) }.freeze

      last_name_p = "((;.+)|(((Mc|Mac|Des|Dell[ae]|Del|De La|De Los|Da|Di|Du|La|Le|Lo|St\.|Den|Von|Van|Von Der|Van De[nr]) )?([#{@nc}]+)))".freeze
      mult_name_p = "((;.+)|(((Mc|Mac|Des|Dell[ae]|Del|De La|De Los|Da|Di|Du|La|Le|Lo|St\.|Den|Von|Van|Von Der|Van De[nr]) )?([#{@nc} ]+)))".freeze

      @m_ericson = { false => /^([[:alpha:]])\.? (#{last_name_p})$/i, true => /^([[:alpha:]])\.? ()$/i }.freeze
      @m_e_ericson = { false => /^([[:alpha:]])\.? ([[:alpha:]])\.? (#{last_name_p})$/i, true => /^([[:alpha:]])\.? ([[:alpha:]])\.? ()$/i }.freeze
      @me_ericson = { false => /^([[:alpha:]])\.([[:alpha:]])\. (#{last_name_p})$/i, true => /^([[:alpha:]])\.([[:alpha:]])\. ()$/i }.freeze
      @m_e_e_ericson = { false => /^([[:alpha:]])\.? ([[:alpha:]])\.? ([[:alpha:]])\.? (#{last_name_p})$/i, true => /^([[:alpha:]])\.? ([[:alpha:]])\.? ([[:alpha:]])\.? ()$/i }.freeze
      @mee_ericson = { false => /^([[:alpha:]])\.([[:alpha:]])\.([[:alpha:]])\. (#{last_name_p})$/i, true => /^([[:alpha:]])\.([[:alpha:]])\.([[:alpha:]])\. ()$/i }.freeze
      @m_edward_ericson = { false => /^([[:alpha:]])\.? ([#{@nc}]+) (#{last_name_p})$/i, true => /^([[:alpha:]])\.? ([#{@nc}]+) ()$/i }.freeze
      @matthew_e_ericson = { false => /^([#{@nc}]+) ([[:alpha:]])\.? (#{last_name_p})$/i, true => /^([#{@nc}]+) ([[:alpha:]])\.? ()$/i }.freeze
      @matthew_e_e_ericson = { false => /^([#{@nc}]+) ([[:alpha:]])\.? ([[:alpha:]])\.? (#{last_name_p})$/i, true => /^([#{@nc}]+) ([[:alpha:]])\.? ([[:alpha:]])\.? ()$/i }.freeze
      @matthew_ee_ericson = { false => /^([#{@nc}]+) ([[:alpha:]]\.[[:alpha:]]\.) (#{last_name_p})$/i, true => /^([#{@nc}]+) ([[:alpha:]]\.[[:alpha:]]\.) ()$/i }.freeze
      @matthew_ericson = { false => /^([#{@nc}]+) (#{last_name_p})$/i, true => /^([#{@nc}]+) ()$/i }.freeze
      @matthew_edward_ericson = { false => /^([#{@nc}]+) ([#{@nc}]+) (#{last_name_p})$/i, true => /^([#{@nc}]+) ([#{@nc}]+) ()$/i }.freeze
      @matthew_e_sheie_ericson = { false => /^([#{@nc}]+) ([[:alpha:]])\.? (#{mult_name_p})$/i, true => /^([#{@nc}]+) ([[:alpha:]])\.? (#{mult_name_p})$/i }.freeze
    end

    def parse( name )
      out = Hash.new( EMPTY )

      out[:orig]  = name.dup

      name = name.dup

      name = clean( name )

      # strip trailing suffices
      @suffixes_commaized.each do |sfx_p|
        name.gsub!( sfx_p, "\\1 \\2".freeze )
      end

      name.gsub!( /Mr\.? \& Mrs\.?/i, "Mr. and Mrs.".freeze )

      # Flip last and first if contain comma
      name.gsub!( /;/, EMPTY )
      name.gsub!( /(.+),(.+)/, "\\2 ;\\1".freeze )


      name.gsub!( /,/, EMPTY )
      name.strip!

      if @opts[:couples]
        name.gsub!( / +and +/i, " \& ".freeze )
      end



      if @opts[:couples] && name.match( /\&/ )

        names = name.split( / *& */ )
        a = names[0]
        b = names[1]

        out[:title2] = get_title( b );
        out[:suffix2] = get_suffix( b );

        b.strip!

        parts = get_name_parts( b )

        out[:parsed2] = parts[0]
        out[:parse_type2] = parts[1]
        out[:first2] = parts[2]
        out[:middle2] = parts[3]
        out[:last] = parts[4]

        out[:title] = get_title( a );
        out[:suffix] = get_suffix( a );

        a.strip!
        a += " ".freeze

        parts = get_name_parts( a, true )

        out[:parsed] = parts[0]
        out[:parse_type] = parts[1]
        out[:first] = parts[2]
        out[:middle] = parts[3]

        if out[:parsed] && out[:parsed2]
          out[:multiple] = true
        else
          out = Hash.new( EMPTY )
        end


      else

        out[:title] = get_title( name );
        out[:suffix] = get_suffix( name );

        parts = get_name_parts( name )

        out[:parsed] = parts[0]
        out[:parse_type] = parts[1]
        out[:first] = parts[2]
        out[:middle] = parts[3]
        out[:last] = parts[4]

      end


      if @opts[:case_mode] == 'proper'.freeze
        [ :title, :first, :middle, :last, :suffix, :clean, :first2, :middle2, :title2, :suffix2 ].each do |part|
          next if part == :suffix && out[part].match( /^[iv]+$/i );
          out[part] = proper( out[part] )
        end
      elsif @opts[:case_mode] == 'upper'.freeze
        [ :title, :first, :middle, :last, :suffix, :clean, :first2, :middle2, :title2, :suffix2 ].each do |part|
          out[part].upcase! if out[part] != EMPTY
        end
      end

      out[:clean] = name

      return {
        :title       => EMPTY,
        :first       => EMPTY,
        :middle      => EMPTY,
        :last        => EMPTY,
        :suffix      => EMPTY,

        :title2      => EMPTY,
        :first2      => EMPTY,
        :middle2     => EMPTY,
        :suffix2     => EMPTY,

        :clean       => EMPTY,

        :parsed      => false,
        :parse_type  => EMPTY,

        :parsed2     => false,
        :parse_type2 => EMPTY,

        :multiple    => false
      }.merge( out )

    end


    def clean( s )

      # remove illegal characters
      s.gsub!( /[^[:alpha:]0-9\-\'\.&\/ \,]/, EMPTY )
      # remove repeating spaces
      s.gsub!( /[[:space:]]+/, " ".freeze )
      s.strip!
      s

    end

    def get_title( name )

      @titles.each do |title_p|
        if m = name.match( title_p )
          title = m[1]
          name.replace( m[-1].strip )
          return title
        end

      end

      return EMPTY
    end

    def get_suffix( name )

      @suffixes_nocomma.each do |sfx_p|
        if name.match( sfx_p )
          name.replace $1.strip
          suffix = $2
          return $2
        end

      end

      return EMPTY
    end

    def get_name_parts( name, no_last_name = false )

      first  = EMPTY
      middle = EMPTY
      last   = EMPTY

      parsed = false

      if name.match( @m_ericson[no_last_name] )
        first  = $1;
        middle = EMPTY;
        last   = $2;
        parsed = true
        parse_type = 1;

      elsif name.match( @m_e_ericson[no_last_name] )
        first  = $1;
        middle = $2;
        last   = $3;
        parsed = true
        parse_type = 2;

      # M.E. ERICSON
      elsif name.match( @me_ericson[no_last_name] )
        first  = $1;
        middle = $2;
        last   = $3;
        parsed = true
        parse_type = 3;

      # M E E ERICSON
      elsif name.match( @m_e_e_ericson[no_last_name] )
        first  = $1;
        middle = $2 + ' '.freeze + $3;
        last   = $4;
        parsed = true
        parse_type = 4;

      # M.E.E. ERICSON
      elsif name.match( @mee_ericson[no_last_name] )
        first  = $1;
        middle = $2 + ' '.freeze + $3;
        last   = $4;
        parsed = true
        parse_type = 4;

      # M EDWARD ERICSON
      elsif name.match( @m_edward_ericson[no_last_name] )
        first  = $1;
        middle = $2;
        last   = $3;
        parsed = true
        parse_type = 5;

      # MATTHEW E ERICSON
      elsif name.match( @matthew_e_ericson[no_last_name] )
        first  = $1;
        middle = $2;
        last   = $3;
        parsed = true
        parse_type = 6;

      # MATTHEW E E ERICSON
      elsif name.match( @matthew_e_e_ericson[no_last_name] )
        first  = $1;
        middle = $2 + ' '.freeze + $3;
        last   = $4;
        parsed = true
        parse_type = 7;

      # MATTHEW E.E. ERICSON
      elsif name.match( @matthew_ee_ericson[no_last_name] )
        first  = $1;
        middle = $2;
        last   = $3;
        parsed = true
        parse_type = 8;

      # MATTHEW ERICSON
      elsif name.match( @matthew_ericson[no_last_name] )
        first  = $1;
        middle = EMPTY;
        last   = $2;
        parsed = true
        parse_type = 9;

      # MATTHEW EDWARD ERICSON
      elsif name.match( @matthew_edward_ericson[no_last_name] )
        first  = $1;
        middle = $2;
        last   = $3;
        parsed = true
        parse_type = 10;

      # MATTHEW E. SHEIE ERICSON
      elsif name.match( @matthew_e_sheie_ericson[no_last_name] )
        first  = $1;
        middle = $2;
        last   = $3;
        parsed = true
        parse_type = 11;
      end

      last.gsub!( /;/, EMPTY )

      return [ parsed, parse_type, first, middle, last ];

    end

    def proper ( name )
      fixed = name.downcase

      # Now uppercase first letter of every word. By checking on word boundaries,
      # we will account for apostrophes (D'Angelo) and hyphenated names
      fixed.gsub!( /\b(\w+)/ ) { |m| m.match( /^[ixv]$+/i ) ? m.upcase :  m.capitalize }

      # Name case Macs and Mcs
      # Exclude names with 1-2 letters after prefix like Mack, Macky, Mace
      # Exclude names ending in a,c,i,o,z or j, typically Polish or Italian

      if fixed.match( /\bMac[a-z]{2,}[^a|c|i|o|z|j]\b/i  )

        fixed.gsub!( /\b(Mac)([a-z]+)/i ) do |m|
          $1 + $2.capitalize
        end

        # Now correct for "Mac" exceptions
        fixed.gsub!( /MacHin/i,  'Machin'.freeze )
        fixed.gsub!( /MacHlin/i, 'Machlin'.freeze )
        fixed.gsub!( /MacHar/i,  'Machar'.freeze )
        fixed.gsub!( /MacKle/i,  'Mackle'.freeze )
        fixed.gsub!( /MacKlin/i, 'Macklin'.freeze )
        fixed.gsub!( /MacKie/i,  'Mackie'.freeze )

        # Portuguese
        fixed.gsub!( /MacHado/i,  'Machado'.freeze );

        # Lithuanian
        fixed.gsub!( /MacEvicius/i, 'Macevicius'.freeze )
        fixed.gsub!( /MacIulis/i,   'Maciulis'.freeze )
        fixed.gsub!( /MacIas/i,     'Macias'.freeze )

      elsif fixed.match( /\bMc/i )
        fixed.gsub!( /\b(Mc)([a-z]+)/i ) do |m|
          $1 + $2.capitalize
        end

      end

      # Exceptions (only 'Mac' name ending in 'o' ?)
      fixed.gsub!( /Macmurdo/i, 'MacMurdo'.freeze )

      return fixed

    end

  end


end

