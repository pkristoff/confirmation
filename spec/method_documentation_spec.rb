# frozen_string_literal: true

describe 'method_documentation' do
  # only want this available when running yhese tests otherwise ignore these spec files
  before(:each) do
    expect(system('cp app/controllers/spec/.spec-rubocop.yml app/controllers/spec/.rubocop.yml')).to eq(true)
  end

  after(:each) do
    expect(system('rm app/controllers/spec/.rubocop.yml')).to eq(true)
  end

  it 'Descriptions documentation' do
    expect_offenses('app/controllers/spec/descriptions_controller.rb',
                    [':13:3: C: Style/PublicMethodDocumentation: Description should not begin with blank comment.',
                     '  #'],
                    [':20:3: C: Style/PublicMethodDocumentation: Description should end with blank comment.',
                     '  # Description should end with a blank comment ***ERROR'],
                    [':35:3: C: Style/PublicMethodDocumentation: Description is missing for missing_descriptions.',
                     '  # === Parameters:'],
                    [':55:3: C: Style/PublicMethodDocumentation: Description is missing for missing_description_with_returns.',
                     '  # === Returns:'],
                    [':79:3: C: Style/PublicMethodDocumentation: Description is missing for description_missing_with_parameters_and_returns.',
                     '  # === Parameters:'],
                    [':93:3: C: Style/PublicMethodDocumentation: Description is missing for description_missing_with_parameters_and_returns2.',
                     '  # === Parameters:'],
                    [':107:3: C: Style/PublicMethodDocumentation: Description is missing for description_missing_with_parameters.',
                     '  # === Parameters:'])
  end

  it 'Parameters documentation' do
    expect_offenses('app/controllers/spec/parameters_controller.rb',
                    [':23:3: C: Style/PublicMethodDocumentation: Parameters should end with blank comment.',
                     '  # * <tt>:arg1</tt> First Parameter'],
                    [":30:3: C: Style/PublicMethodDocumentation: Parameters does not match '# === Parameters:' exactly.",
                     '  # ===  Parameters:'],
                    [':40:3: C: Style/PublicMethodDocumentation: === Parameters: should have a blank comment following it.',
                     '  # === Parameters:'])
  end

  it 'Returns documentation' do
    expect_offenses('app/controllers/spec/returns_controller.rb',
                    [':21:3: C: Style/PublicMethodDocumentation: Returns should end with blank comment.',
                     '  # send_data for spreadsheet'],
                    [":28:3: C: Style/PublicMethodDocumentation: Returns does not match '# === Returns:' exactly.",
                     '  # ===  Returns:'],
                    [':38:3: C: Style/PublicMethodDocumentation: === Returns: should have a blank comment following it.',
                     '  # === Returns:'])
  end

  describe 'no comment' do
    it 'public no comment' do
      expect_offenses('app/controllers/spec/no_comment_controller.rb',
                      [':7:3: C: Style/PublicMethodDocumentation: Missing public method documentation comment for no_comment.',
                       '  def no_comment ...'])
    end
  end

  describe 'arguments' do
    it 'No arguments' do
      expect_offenses('app/controllers/spec/no_args_controller.rb')
    end

    it 'parms greater than arguments' do
      expect_offenses('app/controllers/spec/params_greater_than_args_controller.rb',
                      [':13:3: C: Style/PublicMethodDocumentation: Parameter size 2 does not match argument size 1.',
                       '  # * <tt>:parm2</tt> Second Parameter'],
                      [':25:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                       '  # * <tt>:parm1</tt> First Parameter'],
                      [':26:3: C: Style/PublicMethodDocumentation: Parameter size 2 does not match argument size 1.',
                       '  # * <tt>:parm2</tt> Second Parameter'])
    end

    it 'parms less than arguments' do
      expect_offenses('app/controllers/spec/params_less_than_args_controller.rb',
                      [':13:35: C: Style/PublicMethodDocumentation: Parameter size 1 does not match argument size 2.',
                       '  def params_less_than_args(arg1, arg2)'],
                      [':23:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                       '  # * <tt>:parm1</tt> First Parameter'],
                      [':25:37: C: Style/PublicMethodDocumentation: Parameter size 1 does not match argument size 2.',
                       '  def params_less_than_args_2(arg1, arg2)'])
    end

    describe 'parms and args name mismatch' do
      it 'parm name does not match argument name' do
        expect_offenses('app/controllers/spec/parm_name_does_not_match_argument_name_controller.rb',
                        [':21:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                         '  # * <tt>:parm1</tt> First Parameter'],
                        [':31:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                         '  # * <tt>:parm1</tt> First Parameter'],
                        [':43:3: C: Style/PublicMethodDocumentation: Parameter name parm2 does not match argument name arg2.',
                         '  # * <tt>:parm2</tt> Second Parameter'],
                        [':65:3: C: Style/PublicMethodDocumentation: Parameter name _arg2 does not match argument name arg2.',
                         '  # * <tt>:_arg2</tt> Second Parameter'],
                        [':75:3: C: Style/PublicMethodDocumentation: Parameter name arg2 does not match argument name arg1.',
                         '  # * <tt>:arg2</tt> First Parameter'],
                        [':76:3: C: Style/PublicMethodDocumentation: Parameter name arg1 does not match argument name arg2.',
                         '  # * <tt>:arg1</tt> Second Parameter'])
      end
    end

    describe 'attributes' do
      it '' do
        expect_offenses('app/controllers/spec/attributes_controller.rb',
                        [':19:3: C: Style/PublicMethodDocumentation: === Attributes: should have a blank comment following it.',
                         '  # === Attributes:'],
                        [':30:3: C: Style/PublicMethodDocumentation: Attributes: should end with a blank comment.',
                         '  # * <tt>:id</tt> Candidate id'],
                        [':37:3: C: Style/PublicMethodDocumentation: Attributes and Parameters should not exist on same method.',
                         '  # === Attributes:'],
                        [':49:3: C: Style/PublicMethodDocumentation: Returns should be last.',
                         '  # Attributes should be before Returns'],
                        [':64:3: C: Style/PublicMethodDocumentation: Description is missing for attributes_should_be_before_description.',
                         '  # === Attributes:'])
      end
    end
  end

  def expect_offenses(file, *expected_offenses)
    output = `rubocop -d #{file}`
    # output = system "rubocop -d #{file}"
    if expected_offenses.empty?
      expect($CHILD_STATUS.success?).to eq(true), "expected rubocop no offenses but got exit code: #{$CHILD_STATUS}"
    else
      expect($CHILD_STATUS.success?).to eq(false), "expected rubocop offenses but got exit code: #{$CHILD_STATUS}"
      actual_offenses = offenses(output)
      unless expected_offenses.size == actual_offenses.size
        actual_offenses.each { |off| puts off }
      end
      expect(expected_offenses.size).to eq(actual_offenses.size), "expected #{expected_offenses.size} offense got #{actual_offenses.size}"
      expected_offenses.each_with_index do |off_a, i|
        expect(actual_offenses[i][0]).to eq("#{file}#{off_a[0]}")
        expect(actual_offenses[i][1]).to eq(off_a[1])
      end
    end
  end

  def offenses(output)
    lines = output.split(/\n/)
    begin_offenses = lines.index('Offenses:')
    offs = []
    return offs if begin_offenses.nil?
    i = begin_offenses + 2
    while i < lines.size && i + 3 < lines.size && !lines[i + 1].include?('file inspected')
      offs.push([lines[i], lines[i + 1]])
      i += 3
    end
    offs
  end
end
