module Serve
  class FileResolver
    
    def self.instance
      @instance ||= FileResolver.new
    end
    
    # Resolve a path to a valid file name in root. Return nil if no
    # file exists for that path.
    def resolve(root, path)
      path = normalize_path(path)
      
      return if path.nil? # If it's not a valid path. Return nothing.
      
      full_path = File.join(root, path)
      
      case
      when File.file?(full_path)
        # A file exists! Return the matching path.
        path
      when File.directory?(full_path) 
        # It's a directory? Try a directory index.
        resolve(root, File.join(path, 'index'))
      when path.ends_with?('.css')
        # CSS not found? try SCSS or Sass
        alternates = %w{.scss .sass}.map { |ext| path.sub(/\.css\Z/, ext) }
        sass_path = alternates.find do |p|
          File.file?(File.join(root, p))
        end      
      else
        # Still no luck? Check to see if a file with an extension exists by that name.
        result = Dir.glob(full_path + ".*", File::FNM_CASEFOLD).first
        result.sub(/^#{root}/, '').sub(/^\//, '') if result && File.file?(result)
      end
    end
    
    private
      
      def normalize_path(path)
        path = File.join(path)       # path may be array
        path = path.sub(%r{/\Z}, '') # remove trailing slash
        path unless path =~ /\.\./   # guard against evil paths
      end
      
  end
  
  def self.resolve_filename(*args)
    Serve::FileResolver.instance.resolve(*args)
  end
end
