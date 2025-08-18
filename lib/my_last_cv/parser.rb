module MyLastCV
  class Parser
    def initialize(markdown)
      @markdown = markdown
    end

    def parse
      @result = { sections: [] }
      @current_section = nil
      @current_element = nil
      @pending = []

      lines = @markdown.lines.map(&:chomp)

      lines.each do |raw|
        line = raw.rstrip
        next if line.strip.empty?

        if (m = line.match(/^#\s+(.*)/))
          flush_pending
          @result[:name] = m[1].strip
          @current_section = nil
          @current_element = nil
        elsif (m = line.match(/^(email|phone|location):\s*(.+)/i))
          (@result[:contact] ||= []) << m[2].strip
        elsif (m = line.match(/^##\s+(.*)/))
          flush_pending
          @current_section = { title: m[1].strip, items: [], elements: [] }
          @result[:sections] << @current_section
          @current_element = nil
        elsif (m = line.match(/^###\s+(.*)/))
          flush_pending
          handle_element(m[1].strip)
        elsif (m = line.match(/^[-*]\s+(.*)/))
          handle_bullet(m[1].strip)
        else
          @pending << line.strip
        end
      end

      flush_pending

      @result[:contact] = (@result[:contact] || []).join(" · ")
      @result
    end

    private

    def flush_pending
      if @current_element
        flush_pending_to(@current_element)
      elsif @current_section
        flush_pending_to(@current_section)
      else
        flush_pending_nowhere
      end
    end

    def flush_pending_to(target)
      return if @pending.empty?
      text = @pending.join(' ').strip
      @pending.clear
      return if text.empty?
      target[:items] ||= []
      target[:items] << { type: :paragraph, text: text }
    end

    def flush_pending_nowhere
      return if @pending.empty?
      text = @pending.join(' ').strip
      @pending.clear
      return if text.empty?
      @result[:intro] ||= []
      @result[:intro] << text
    end

    def ensure_current_section
      return @current_section if @current_section
      @current_section = { title: 'Divers', items: [], elements: [] }
      @result[:sections] << @current_section
      @current_section
    end

    def handle_element(title)
      ensure_current_section if @current_section.nil?
      @current_element = { title: title.strip, items: [] }
      @current_section[:elements] ||= []
      @current_section[:elements] << @current_element
    end

    def handle_bullet(text)
      ensure_current_section if @current_section.nil?
      item = { type: :bullet, text: text.strip }
      if @current_element
        flush_pending_to(@current_element)
        @current_element[:items] << item
      else
        flush_pending_to(@current_section)
        @current_section[:items] << item
      end
    end
  end
end

