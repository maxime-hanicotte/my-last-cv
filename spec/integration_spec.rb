require 'spec_helper'
require 'tmpdir'

RSpec.describe 'MyLastCV integration' do
  it 'generates a PDF from markdown using MyLastCV.generate' do
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

      expect do
        MyLastCV.generate(input_path, output_path)
      end.not_to raise_error

      expect(File).to exist(output_path)
      expect(File.size(output_path)).to be > 0
    end
  end
end
