require 'prawn'

module MyLastCV
  class Renderer
    def initialize(parsed_cv, style: Style.new)
      @parsed_cv = parsed_cv
      @style = style
    end

    def to_pdf(output_path)
      Prawn::Document.generate(output_path, **@style.page_options) do |pdf|
        render_header(pdf)
        render_sections(pdf)
      end
    end

    private

    def render_header(pdf)
      pdf.font(@style.header_font)
      pdf.move_down 12
      pdf.text(@parsed_cv[:name] || '-', size: @style.header_size, align: :center)
      pdf.move_down 6
      pdf.font(@style.body_font)
      pdf.text(@parsed_cv[:contact] || '', size: @style.body_size, align: :center)
      pdf.stroke_horizontal_rule
      pdf.move_down 12
    end

    def render_sections(pdf)
      @parsed_cv[:sections].each do |section|
        pdf.move_down 8
        pdf.font(@style.section_font)
        pdf.text(section[:title], size: @style.section_size, style: :bold)
        pdf.move_down 4
        pdf.font(@style.body_font)
        section[:items].each do |item|
          pdf.text("• #{item}", size: @style.body_size, indent_paragraphs: 16)
        end
      end
    end
  end
end
