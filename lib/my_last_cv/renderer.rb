require 'prawn'
require 'fileutils'

module MyLastCV
  class Renderer
    def initialize(parsed_cv, style: Style.new)
      @parsed_cv = parsed_cv
      @style = style
    end

    def to_pdf(output_path)
      FileUtils.mkdir_p(File.dirname(output_path))
      Prawn::Document.generate(output_path, **@style.page_options) do |pdf|
        register_fonts(pdf)
        render_header(pdf)
        render_sections(pdf)
      end
    end

    private

    def resolved_fonts_dir
      candidates = []
      candidates << @style.fonts_dir if @style.fonts_dir
      candidates << ENV["MY_LAST_CV_FONTS_DIR"] if ENV["MY_LAST_CV_FONTS_DIR"]
      candidates << File.join(Dir.pwd, "fonts")

      # fallback if no fonts_dir specified
      candidates << File.expand_path("../../fonts", __dir__)

      candidates.find { |p| p && Dir.exist?(p) }
    end

    def register_fonts(pdf)
      fonts_dir = resolved_fonts_dir
      return unless fonts_dir

      # Exemple : Inter (Regular / Bold)
      pdf.font_families.update(
        "Inter" => {
          normal: File.join(fonts_dir, "Inter-Regular.ttf"),
          bold:   File.join(fonts_dir, "Inter-Bold.ttf")
        },
        "Lora" => {
          normal: File.join(fonts_dir, "Lora-Regular.ttf"),
          bold:   File.join(fonts_dir, "Lora-Bold.ttf")
        }
      )
    end

    def render_header(pdf)
      pdf.font(@style.header_font)
      pdf.move_down 12
      with_color(pdf, @style.accent_color) do
        pdf.text(@parsed_cv[:name] || '-', size: @style.header_size, align: :center)
      end
      pdf.move_down 6
      pdf.font(@style.body_font)
      pdf.text(@parsed_cv[:contact] || '', size: @style.body_size, align: :center)

      if @parsed_cv[:intro]&.any?
        pdf.move_down 10
        @parsed_cv[:intro].each do |p|
          pdf.text(p, size: @style.body_size, leading: 2)
          pdf.move_down 4
        end
      else
        pdf.move_down 4
      end

      with_color(pdf, @style.accent_color) do
        pdf.stroke_horizontal_rule
      end
      pdf.move_down 12
    end

    def render_sections(pdf)
      (@parsed_cv[:sections] || []).each do |section|
        pdf.move_down 8
        pdf.font(@style.section_font)
        pdf.text(section[:title], size: @style.section_size, style: :bold)

        render_items(pdf, section[:items])

        (section[:elements] || []).each do |el|
          pdf.move_down 6
          pdf.font(@style.section_font)
          pdf.text(el[:title], size: (@style.section_size - 3), style: :bold)
          render_items(pdf, el[:items])
        end
      end
    end

    def render_items(pdf, items)
      return if items.nil? || items.empty?

      pdf.move_down 4
      pdf.font(@style.body_font)

      (items || []).each do |item|
        case item[:type]
        when :bullet
          pdf.text("• #{item[:text]}", size: @style.body_size, indent_paragraphs: 16)
        when :paragraph
          pdf.text(item[:text], size: @style.body_size, leading: 2)
          pdf.move_down 4
        else
          # fallback (au cas où)
          pdf.text(item.to_s, size: @style.body_size)
        end
      end
    end

    def with_color(pdf, hex)
      return yield if hex.to_s.strip.empty?
      previous = pdf.fill_color
      pdf.fill_color(hex)
      yield
    ensure
      pdf.fill_color(previous) if previous
    end
  end
end
