# frozen_string_literal: true

describe 'method_documentation' do
  describe 'no comment' do

    it 'public no comment' do
      expect_offenses('app/controllers/spec/no_comment_controller.rb',
                      [':7:3: C: Style/PublicMethodDocumentation: Missing public method documentation comment for no_comment.',
                       '  def no_comment ...'])
    end
  end

  describe 'arguments' do
    it 'parms greater than arguments' do
      expect_offenses('app/controllers/spec/params_greater_than_args_controller.rb',
                      [':13:3: C: Style/PublicMethodDocumentation: Parameter size 2 does not match argument size 1.',
                       '  # * <tt>_parm2_</tt> Second Parameter'],
                      [':25:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                       '  # * <tt>_parm1_</tt> First Parameter'],
                      [':26:3: C: Style/PublicMethodDocumentation: Parameter size 2 does not match argument size 1.',
                       '  # * <tt>_parm2_</tt> Second Parameter'])
    end

    it 'parms less than arguments' do
      expect_offenses('app/controllers/spec/params_less_than_args_controller.rb',
                      [':13:35: C: Style/PublicMethodDocumentation: Parameter size 1 does not match argument size 2.',
                       '  def params_less_than_args(arg1, arg2)'],
                      [':21:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                       '  # * <tt>_parm1_</tt> First Parameter'],
                      [':23:37: C: Style/PublicMethodDocumentation: Parameter size 1 does not match argument size 2.',
                       '  def params_less_than_args_2(arg1, arg2)'])
    end

    describe 'parms and args name mismatch' do
      it 'parm name does not match argument name' do
        expect_offenses('app/controllers/spec/parm_name_does_not_match_argument_name_controller.rb',
                        [':21:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                         '  # * <tt>_parm1_</tt> First Parameter'],
                        [':31:3: C: Style/PublicMethodDocumentation: Parameter name parm1 does not match argument name arg1.',
                         '  # * <tt>_parm1_</tt> First Parameter'],
                        [':43:3: C: Style/PublicMethodDocumentation: Parameter name parm2 does not match argument name arg2.',
                         '  # * <tt>_parm2_</tt> Second Parameter'],
                        [':53:3: C: Style/PublicMethodDocumentation: Parameter name arg2 does not match argument name arg1.',
                         '  # * <tt>_arg2_</tt> First Parameter'],
                        [':54:3: C: Style/PublicMethodDocumentation: Parameter name arg1 does not match argument name arg2.',
                         '  # * <tt>_arg1_</tt> Second Parameter'])
      end
    end
  end

  def expect_offenses(file, *expected_offenses)
    output = `rubocop -d  #{file}`
    # output = system "rubocop -d #{file}"
    expect($?.success?).to eq(false), 'expected rubocop offenses'
    actual_offenses = offenses(output)
    expect(expected_offenses.size).to eq(actual_offenses.size), "expected #{expected_offenses.size} offense got #{actual_offenses.size}"
    expected_offenses.each_with_index do |off_a, i|
      expect(actual_offenses[i][0]).to eq("#{file}#{off_a[0]}")
      expect(actual_offenses[i][1]).to eq(off_a[1])
    end
  end

  def offenses(output)
    lines = output.split(/\n/)
    begin_offenses = lines.index('Offenses:')
    offs = []
    i = begin_offenses + 2
    while i < lines.size && i + 3 < lines.size && !lines[i + 1].include?('file inspected')
      offs.push([lines[i], lines[i + 1]])
      i += 3
    end
    offs
  end
end
