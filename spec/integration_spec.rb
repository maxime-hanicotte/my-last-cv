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

  it 'generates a PDF with inline markdown formatting and embeds links' do
    markdown = <<~MD
      # Jane Doe
      website: [Portfolio](https://example.com)

      ## Experience
      Paragraph with **bold**, *italic*, and `code`.
      - Built [features](https://example.com/features)
    MD

    Dir.mktmpdir do |dir|
      input_path = File.join(dir, 'cv.md')
      output_path = File.join(dir, 'cv.pdf')
      File.write(input_path, markdown)

      expect do
        MyLastCV.generate(input_path, output_path)
      end.not_to raise_error

      pdf = File.binread(output_path)
      expect(pdf).to include('https://example.com')
      expect(pdf).to include('https://example.com/features')
    end
  end
end
