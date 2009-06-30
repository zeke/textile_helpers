module TextileHelpers
  
  module PublicMethods

    def textilize_plus string=nil, options={}
      # Handle bad arguments
      return if string.blank?
      return unless string.is_a? String
    
      # Configure options
      options[:paragraph] = true if options[:paragraph].nil?
      options[:replace_wonky] = true if options[:replace_wonky].nil?
      options[:repair_markup] = true if options[:repair_markup].nil?
      options[:heading_ids] = true if options[:heading_ids].nil?
      options[:wrap_in_div] = true if options[:wrap_in_div].nil?

      # Add 'textilized' class to any existing CSS styles
      options[:class] = "" if options[:class].nil?
      options[:class] = options[:class].split(" ").push("textilized").join(" ")
    
      # Clean up string
      string = replace_wonky_characters_with_ascii(string) if options[:replace_wonky]
      string = repair_faulty_textile_heading_markup(string) if options[:repair_markup]
      string = add_id_attribute_to_textile_headings(string) if options[:heading_ids]
      string = options[:paragraph] ? textilize(string) : textilize_without_paragraph(string)
      return content_tag(:div, string, :class => options[:class]) if options[:wrap_in_div]
      string
    end

    # Replaces all h1, h2, and h3 headings with name attributes
    # The value of the name attribute is based on a 'permalinked' version of the heading text
    # (This should use a regex like the other methods, but it's okay for now)
    def add_id_attribute_to_textile_headings string, options={}
      delimiter = options[:delimiter] || "\n"
      
      new_string = replace_wonky_characters_with_ascii(string)
      new_string = repair_faulty_textile_heading_markup(new_string)
      
      output = []
      new_string.split(delimiter).each do |line|
        tag = line.split(" ").first.downcase rescue nil # Looking for lines starting with h1, h2, or h3
        if %w(h1. h2. h3.).include?(tag)
          heading = line.gsub(tag, "").strip # Get heading text without the tag part
          anchor = permalinkify(heading)
          line = "#{tag.gsub(".", "")}(##{anchor}). #{heading}"
        end
        output << line
      end
      output.join(delimiter)
    end

    def repair_faulty_textile_heading_markup string
      output = string.to_s
      output.gsub!("\r\n", "\n") # Replace carriage returns with regular newlines
      output.scan(/^h\d+. .*$/i).map { |h| output.gsub!(h, h+"\n") } # Add a newline after all headings
      output.gsub("\n\n\n", "\n\n")  # Replace instances of 3 newlines with 2
    end
  
    def table_of_contents_for string, options={}
      # Handle bad arguments
      return if string.blank?
      return unless string.is_a? String
      
      # Handle options
      options[:heading] ||= "Table of Contents"
      options[:max_size] ||= 3 # Only allow h1, h2, and h3
      
      links = []
      textilize_plus(string).scan(/\<h\d+.*\<\/h\d+\>/i).map do |h|
        size = h.scan(/h(\d+)/i).first.first.to_i # the number part of the heading, e.g. 1, 2, etc
        next if size > options[:max_size]
        inner_html = h.gsub(/<\/?[^>]*>/, "") # Strip HTML tags
        id = h.scan(/id=\"(.*)\"/i).first.first # DOM id of the heading tag
        links << link_to(inner_html, "##{permalinkify(replace_wonky_characters_with_ascii(inner_html))}", :class => "h#{size}")
      end
      return if links.blank?
    
      # Build list items from links
      items = []
      links.each_with_index do |link, index|
        css = []
        css << "first" if index == 0
        css << "last" if index == links.size-1
        items << content_tag(:li, link, :class => css.join(" "))
      end
      
      output = []    
      output << content_tag(:h1, options[:heading], :class => "textile_toc_heading") if options[:heading]
      output << content_tag(:ul, items.join("\n"), :class => "textile_toc")
      output.join("\n")
    end

    def replace_wonky_characters_with_ascii string
      o = string.dup
      o.gsub!('—', '-')
      o.gsub!('–', '--')
      o.gsub!('…', '...')
      o.gsub!('’', "'")
      o.gsub!('‘', "'")
      o.gsub!('“', '"')
      o.gsub!('”', '"')
      o
    end
    
    # Generates a permalink-style representation of a string
    # (Snagged from permalink_fu)
    def permalinkify(string)
      string.
        gsub(/[^\x00-\x7F]+/, ''). # Remove anything non-ASCII entirely (e.g. diacritics).
        gsub(/[^\w_ \-]+/i,   ''). # Remove unwanted chars.
        gsub(/[ \-]+/i,      '-'). # No more than one of the separator in a row.
        gsub(/^\-|\-$/i,      ''). # Remove leading/trailing separator.
        downcase
    end
    
  end



end