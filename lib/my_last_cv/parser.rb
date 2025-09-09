require 'yaml'

module MyLastCV
  class Parser
    LineHandler = Struct.new(:pattern, :method)

    HANDLERS = [
      LineHandler.new(/^(name|title|email|phone|linkedin|github|website|location):\s*(.+)/i, :handle_contact),
      LineHandler.new(/^#\s+(.*)/, :handle_title),
      LineHandler.new(/^##\s+(.*)/, :handle_section),
      LineHandler.new(/^###\s+(.*)/, :handle_element),
      LineHandler.new(/^[-*]\s+(.*)/, :handle_bullet)
    ].freeze

    CONTACT_KEYS = %w[name title email phone linkedin github website location].freeze

    def initialize(markdown)
      @markdown = markdown
    end

    def parse
      setup_state
      extract_front_matter!
      @markdown.each_line do |raw|
        line = raw.rstrip

        stripped = line.strip
        next if stripped.empty? || stripped == '---'

        handler = HANDLERS.find { |h| h.pattern.match?(line) }
        if handler
          send(handler.method, line)
        else
          handle_text(line)
        end
      end

      finalize
      @result
    end

    private

    def setup_state
      @result = { sections: [] }
      @current_section = nil
      @current_element = nil
      @pending = []
    end

    def extract_front_matter!
      lines = @markdown.lines
      return if lines.empty?
      return unless lines.first&.strip == '---'

      closing_index = lines[1..]&.find_index { |l| l.strip == '---' }
      return unless closing_index

      closing_index += 1

      yaml_content = lines[1...closing_index].join
      rest = lines[(closing_index + 1)..] || []

      begin
        data = YAML.safe_load(yaml_content) || {}
      rescue StandardError
        data = {}
      end

      if data.is_a?(Hash)
        # Prefer explicit YAML title if present
        @result[:title] = data['title'].to_s.strip unless data['title'].to_s.strip.empty?

        CONTACT_KEYS.each do |k|
          v = data[k]
          next if v.nil? || v.to_s.strip.empty?
          @result[:contact] ||= {}
          @result[:contact][k] = v.to_s.strip
        end
      end

      @markdown = rest.join
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

    def handle_title(line)
      flush_pending_current
      @result[:title] = line.sub(/^#\s+/, "").strip
      @current_section = nil
      @current_element = nil
    end

    def handle_contact(line)
      key, value = line.split(":", 2)
      @result[:contact] ||= {}
      @result[:contact][key] = value.strip
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
