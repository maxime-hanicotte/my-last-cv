require 'spec_helper'
require 'tmpdir'
require 'open3'

RSpec.describe 'my_last_cv CLI' do
  it 'returns usage and exits with code 1 when arguments are missing' do
    stdout, stderr, status = Open3.capture3('ruby exe/my_last_cv')

    expect(status.exitstatus).to eq(1)
    expect(stdout).to include('Usage: my_last_cv input.md output.pdf')
    expect(stderr).to eq('')
  end

  it 'generates a PDF when given valid input and output paths' do
    markdown = <<~MD
      # Jane Doe
      email: jane@example.com

      ## Experience
      - Built web apps
    MD

    Dir.mktmpdir do |dir|
      input_path = File.join(dir, 'cv.md')
      output_path = File.join(dir, 'cv.pdf')
      File.write(input_path, markdown)

      stdout, stderr, status = Open3.capture3('ruby', 'exe/my_last_cv', input_path, output_path)

      expect(status.success?).to be(true)
      expect(stderr).to eq('')
      expect(stdout).to include('CV généré :')
      expect(File).to exist(output_path)
      expect(File.size(output_path)).to be > 0
    end
  end
end
