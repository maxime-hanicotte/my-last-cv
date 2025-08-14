module MyLastCV
  class Parser
    def initialize(markdown)
      @markdown = markdown
    end

    def parse
      lines = @markdown.lines.map(&:chomp)
      result = { sections: [] }

      current_section = nil
      current_element = nil

      # buffer
      pending = []

      # helpers
      flush_pending_to = lambda do |target|
        return if pending.empty?
        text = pending.join(" ").strip
        pending.clear
        return if text.empty?
        target[:items] ||= []
        target[:items] << { type: :paragraph, text: text }
      end

      flush_pending_nowhere = lambda do
        return if pending.empty?
        text = pending.join(" ").strip
        pending.clear
        return if text.empty?
        result[:intro] ||= []
        result[:intro] << text
      end

      lines.each do |raw|
        line = raw.rstrip
        next if line.strip.empty?

        if (m = line.match(/^#\s+(.*)/)) # New header
          if current_element
            flush_pending_to.call(current_element)
          elsif current_section
            flush_pending_to.call(current_section)
          else
            flush_pending_nowhere.call
          end

          result[:name] = m[1].strip
          current_section = nil
          current_element = nil

        elsif (m = line.match(/^(email|phone|location):\s*(.+)/i))
          (result[:contact] ||= []) << m[2].strip

        elsif (m = line.match(/^##\s+(.*)/)) # New section
          if current_element
            flush_pending_to.call(current_element)
          elsif current_section
            flush_pending_to.call(current_section)
          else
            flush_pending_nowhere.call
          end

          current_section = { title: m[1].strip, items: [], elements: [] }
          result[:sections] << current_section
          current_element = nil

        elsif (m = line.match(/^###\s+(.*)/)) # New element
          if current_element
            flush_pending_to.call(current_element)
          elsif current_section
            flush_pending_to.call(current_section)
          else
            flush_pending_nowhere.call
          end

          current_section ||= { title: "Divers", items: [], elements: [] }
          result[:sections] << current_section unless result[:sections].include?(current_section)

          current_element = { title: m[1].strip, items: [] }
          current_section[:elements] ||= []
          current_section[:elements] << current_element

        elsif (m = line.match(/^[-*]\s+(.*)/)) # Bullet point
          item = { type: :bullet, text: m[1].strip }
          if current_element
            flush_pending_to.call(current_element)
            current_element[:items] << item
          elsif current_section
            flush_pending_to.call(current_section)
            current_section[:items] << item
          else
            current_section = { title: "Divers", items: [item], elements: [] }
            result[:sections] << current_section
          end

        else
          pending << line.strip
        end
      end

      # End of parsing, flush any remaining pending text
      if current_element
        flush_pending_to.call(current_element)
      elsif current_section
        flush_pending_to.call(current_section)
      else
        flush_pending_nowhere.call
      end

      result[:contact] = (result[:contact] || []).join(" · ")
      result
    end
  end
end
