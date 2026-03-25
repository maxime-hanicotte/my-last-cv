require 'spec_helper'
require 'tmpdir'

RSpec.describe MyLastCV::Renderer do
  it 'renders a PDF when contact is missing' do
    parsed_cv = {
      title: 'Jean Dupont',
      sections: [
        { title: 'Experience', items: [{ type: :bullet, text: 'Developed features' }], elements: [] }
      ]
    }

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, 'cv.pdf')

      expect do
        described_class.new(parsed_cv).to_pdf(output_path)
      end.not_to raise_error

      expect(File).to exist(output_path)
      expect(File.size(output_path)).to be > 0
    end
  end
end
