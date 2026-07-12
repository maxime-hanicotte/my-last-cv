require 'spec_helper'
require 'tmpdir'

RSpec.describe MyLastCV::Renderer do
  let(:fake_pdf) do
    Class.new do
      attr_reader :text_calls, :icon_calls, :font_families

      def initialize
        @text_calls = []
        @icon_calls = []
        @font_families = {}
        @fill_color = '000000'
        @stroke_color = '000000'
      end

      def move_down(*); end
      def font(*); end
      def stroke_horizontal_rule; end

      def text(content, **options)
        @text_calls << [content, options]
      end

      def icon(content, **options)
        @icon_calls << [content, options]
      end

      def fill_color(value = nil)
        return @fill_color if value.nil?

        @fill_color = value
      end

      def stroke_color(value = nil)
        return @stroke_color if value.nil?

        @stroke_color = value
      end
    end.new
  end

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

  it 'renders inline markdown content with Prawn inline formatting enabled' do
    parsed_cv = {
      title: 'Jean Dupont',
      contact: {
        'website' => '[Portfolio](https://example.com)'
      },
      intro: ['Intro **importante**'],
      sections: [
        {
          title: 'Experience',
          items: [
            { type: :paragraph, text: 'Texte avec *italique*' },
            { type: :bullet, text: 'Code `puts`' }
          ],
          elements: []
        }
      ]
    }

    allow(Prawn::Document).to receive(:generate).and_yield(fake_pdf)

    described_class.new(parsed_cv).to_pdf('/tmp/cv.pdf')

    expect(fake_pdf.icon_calls).to include(
      [
        a_string_including('<link href="https://example.com">Portfolio</link>'),
        hash_including(inline_format: true)
      ]
    )
    expect(fake_pdf.text_calls).to include(
      ['Intro <b>importante</b>', hash_including(size: kind_of(Numeric), leading: 2, inline_format: true)],
      ['Texte avec <i>italique</i>', hash_including(size: kind_of(Numeric), leading: 2, inline_format: true)]
    )
    expect(fake_pdf.text_calls).to include(
      [
        a_string_including('<font name="Courier">puts</font>'),
        hash_including(size: kind_of(Numeric), indent_paragraphs: 16, inline_format: true)
      ]
    )
  end
end
