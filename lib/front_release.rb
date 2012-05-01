module FrontRelease
  
  def self.hash(path = nil)
    path ||= File.join(File.dirname(__FILE__), '..', 'FRONT_RELEASE')
    hash = 'none'
    File.open(path) { |f| hash = f.read }
    hash
  end

end