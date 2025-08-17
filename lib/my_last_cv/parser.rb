module MyLastCV
  class Parser
    LineHandler = Struct.new(:pattern, :method)

    HANDLERS = [
      LineHandler.new(/^#\s+(.*)/, :handle_name),
      LineHandler.new(/^(email|phone|location):\s*(.+)/i, :handle_contact),
      LineHandler.new(/^##\s+(.*)/, :handle_section),
      LineHandler.new(/^###\s+(.*)/, :handle_element),
      LineHandler.new(/^[-*]\s+(.*)/, :handle_bullet)
    ].freeze

    def initialize(markdown)
      @markdown = markdown
    end

    def parse
      setup_state
      @markdown.each_line do |raw|
        line = raw.rstrip
        next if line.strip.empty?

        handler = HANDLERS.find { |h| h.pattern.match?(line) }
        if handler
          send(handler.method, line)
        else
          handle_text(line)
        end
      end

      finalize
      @result[:contact] = (@result[:contact] || []).join(" · ")
      @result
    end

    private

    def setup_state
      @result = { sections: [] }
      @current_section = nil
      @current_element = nil
      @pending = []
    end

    def flush_pending_to(target)
      return if @pending.empty?
      text = @pending.join(" ").strip
      @pending.clear
      return if text.empty?
      target[:items] ||= []
      target[:items] << { type: :paragraph, text: text }
    end

    def flush_pending_nowhere
      return if @pending.empty?
      text = @pending.join(" ").strip
      @pending.clear
      return if text.empty?
      (@result[:intro] ||= []) << text
    end

    def finalize
      if @current_element
        flush_pending_to(@current_element)
      elsif @current_section
        flush_pending_to(@current_section)
      else
        flush_pending_nowhere
      end
    end

    def flush_pending_current
      if @current_element
        flush_pending_to(@current_element)
      elsif @current_section
        flush_pending_to(@current_section)
      else
        flush_pending_nowhere
      end
    end

    def handle_name(line)
      flush_pending_current
      @result[:name] = line.sub(/^#\s+/, "").strip
      @current_section = nil
      @current_element = nil
    end

    def handle_contact(line)
      _, value = line.split(":", 2)
      (@result[:contact] ||= []) << value.strip
    end

    def handle_section(line)
      flush_pending_current
      @current_section = { title: line.sub(/^##\s+/, "").strip, items: [], elements: [] }
      @result[:sections] << @current_section
      @current_element = nil
    end

    def handle_element(line)
      flush_pending_current
      @current_section ||= { title: "Divers", items: [], elements: [] }
      @result[:sections] << @current_section unless @result[:sections].include?(@current_section)
      @current_element = { title: line.sub(/^###\s+/, "").strip, items: [] }
      @current_section[:elements] ||= []
      @current_section[:elements] << @current_element
    end

    def handle_bullet(line)
      item = { type: :bullet, text: line.sub(/^[-*]\s+/, "").strip }
      if @current_element
        flush_pending_to(@current_element)
        @current_element[:items] << item
      elsif @current_section
        flush_pending_to(@current_section)
        @current_section[:items] << item
      else
        @current_section = { title: "Divers", items: [item], elements: [] }
        @result[:sections] << @current_section
      end
    end

    def handle_text(line)
      @pending << line.strip
    end
  end
end

