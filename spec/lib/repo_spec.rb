require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'fileutils'

describe "Repo" do

  before :each do
    @test_repo_url = 'http://github.com/mojombo/grit.git'
    @test_repo_location = "#{RAILS_ROOT}/data/repositories/grit.git"
  end

  describe "class methods" do
    
    subject { Repo }
    
    describe ".find" do      
      it "returns a repo object" do
        repo = subject.find(@test_repo_url)
        repo.class.should == Grit::Repo
      end    
    end
    
    describe ".update_or_create_bare_repo" do
      
      context "if a repo does exist" do
        before(:each) do
          subject.stub(:repo_exists?).and_return true
        end

        it "updates a bare repo if it already exists" do
          subject.should_receive(:update_repo)
          subject.update_or_create_bare_repo(@test_repo_url)
        end        
      end

      context "if a repo does not exist" do
        before(:each) do
          subject.stub(:repo_exists?).and_return false
          `git init --bare #{@test_repo_location}`
        end

        after(:each) do
          FileUtils.rm_rf @test_repo_location
        end

        it "clones a bare repo if it doesn't exist" do
          subject.should_receive(:clone_bare_repo)
          subject.update_or_create_bare_repo(@test_repo_location)
        end
      end
    end
    
    it "clones a bare repository to the repositories directory" do
      subject.clone_bare_repo(@test_repo_url)
      File.directory?(@test_repo_location).should == true
      FileUtils.rm_rf @test_repo_location
    end

    describe ".update_repo" do
      it "updates the bare repo from the remote master branch"
    end

    describe ".repo_exists?" do
      context "if a repo does exist" do
        it "returns true" do
          `git init --bare #{@test_repo_location}`
          subject.repo_exists?(@test_repo_url).should == true
          FileUtils.rm_rf @test_repo_location
        end
      end

      context "if a repo does not exist" do
        it "returns false" do
          subject.repo_exists?(@test_repo_url).should == false
        end
      end
    end

    it "returns the path to the repo" do
      File.expand_path(subject.get_repo_path(@test_repo_url)).should == File.expand_path(@test_repo_location)
    end

    it "returns the repository name of the bare git repository" do
      subject.get_repo_name(@test_repo_url).should == "grit.git"
    end
    
  end
end
