module MyLastCV
  class Style
    attr_reader :header_font, :header_size, :section_font, :section_size, :body_font, :body_size, :page_options, :accent_color

    def initialize(opts = {})
      @header_font  = opts[:header_font]  || 'Helvetica'
      @header_size  = opts[:header_size]  || 18
      @section_font = opts[:section_font] || 'Helvetica'
      @section_size = opts[:section_size] || 12
      @body_font    = opts[:body_font]    || 'Helvetica'
      @body_size    = opts[:body_size]    || 10
      @page_options = opts[:page_options] || { margin: 48 }
      @accent_color = opts[:accent_color] || '000000'
    end
  end
end
