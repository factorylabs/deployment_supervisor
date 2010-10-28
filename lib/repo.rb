require 'grit'

class Repo

  # class methods
  
  def self.find(url)
    Grit::Repo.new(self.update_or_create_bare_repo(url))    
  end
  
  def self.update_or_create_bare_repo(url)
    if self.repo_exists?(url)
      location = self.update_repo(url)
    else
      location = self.clone_bare_repo(url)
    end
    location
  end

  def self.clone_bare_repo(url)
    repo_location = self.get_repo_path(url)
    `git clone --bare #{url} #{repo_location}`    
    repo_location
  end
  
  def self.update_repo(url)
    repo_location = self.get_repo_path(url)
    #attempt a pull or fetch - why won't grit do this?!
    `cd repo_location && git pull`
  end
  
  def self.repo_exists?(url)
    File.directory? self.get_repo_path(url)
  end
  
  def self.get_repo_path(url)
    "#{RAILS_ROOT}/data/repositories/#{self.get_repo_name(url)}"
  end
  
  def self.get_repo_name(url)
    url.split('/').last
  end
end