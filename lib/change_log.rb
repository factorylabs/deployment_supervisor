require 'grit'

class ChangeLog
  def initialize(url, options={})
    repo_dir = self.find_or_create_bare_repo(url)
    @repo = Grit::Repo.new(repo_dir)
  end

  # class methods

  def self.find_or_create_bare_repo(url)
    if self.repo_exists?(url)
      self.update_repo(url)
    else
      self.clone_bare_repo(url)
    end
  end

  def self.clone_bare_repo(url)
    `git clone --bare #{url} #{self.get_repo_path(url)}`
  end

  def self.update_repo(url)
    #todo
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