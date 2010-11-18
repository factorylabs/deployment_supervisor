require 'grit'

class Repo

  attr_accessor :url

  delegate :commits, :to => :grit_repo

  # class methods

  # def grit_repo
    # @grit_repo ||= Grit::Repo.new(self.update_or_create_bare_repo(url))
  # end

  def initialize(url)
    self.url = url
    self
  end

  def pull_or_clone
    if exists?
      location = pull
    else
      location = clone_bare
    end
    location
  end

  def clone_bare
    repo_location = path
    `git clone --bare #{url} #{repo_location}`    
    repo_location
  end
  
  def pull
    `cd #{path} && git pull`
  end
  
  def exists?
    File.directory? path
  end
  
  def path
    "#{Rails.root.to_s}/data/repositories/#{self.name}"
  end
  
  def name
    url.split('/').last
  end
end
