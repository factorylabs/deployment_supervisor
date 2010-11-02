require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'fileutils'

describe "Repo" do

  before :each do
    @test_repo_url = 'http://github.com/mojombo/grit.git'
    @repo_dir = "#{Rails.root.to_s}/data/repositories/"
    @test_repo_location = "#{@repo_dir}grit.git"
  end

  subject { Repo.find(@test_repo_url) }

  describe "#name" do
    it "returns the repository name of the bare git repository" do
      subject.name.should == "grit.git"
    end
  end

  describe "#path" do
    it "returns the path to the repo" do
      File.expand_path(subject.path).should == File.expand_path(@test_repo_location)
    end
  end

    describe "#exists?" do
      context "if a repo does exist" do
        it "returns true" do
          `git init --bare #{@test_repo_location}`
          subject.exists?.should == true
          FileUtils.rm_rf @test_repo_location
        end
      end

      context "if a repo does not exist" do
        it "returns false" do
          subject.exists?.should == false
        end
      end
    end

    describe "#clone_bare" do
      it "clones a bare repository to the repositories directory" do
        subject.clone_bare
        File.directory?(@test_repo_location).should == true
        FileUtils.rm_rf @test_repo_location
      end
    end

  describe "#update_repo" do
    it "updates the bare repo from the remote master branch" do
      `cd #{@repo_dir} &&
       git init remote &&
       cd remote &&
       echo 'some text' > file.txt &&
       git add file.txt &&
       git commit -m 'add file'`
      `git clone -l #{@repo_dir}remote #{@test_repo_location}`
      File.exist?("#{@test_repo_location}/file.txt").should == true
      `cd #{@repo_dir}/remote &&
       echo 'more text' > new.txt &&
       git add new.txt &&
       git commit -m 'add another file'`
      subject.pull
      File.exist?("#{@test_repo_location}/new.txt").should == true
      FileUtils.rm_rf [@test_repo_location, "#{@repo_dir}/remote"]
    end
  end


  describe "#pull_or_clone" do

    context "if a repo does exist" do
      before(:each) do
        subject.stub(:exists?).and_return true
      end

      it "updates a bare repo if it already exists" do
        subject.should_receive(:pull)
        subject.pull_or_clone
      end
    end

    context "if a repo does not exist" do
      before(:each) do
        subject.stub(:exists?).and_return false
        `git init --bare #{@test_repo_location}`
      end

      after(:each) do
        FileUtils.rm_rf @test_repo_location
      end

      it "clones a bare repo if it doesn't exist" do
        subject.should_receive(:clone_bare)
        subject.pull_or_clone
      end
    end
  end

  describe "class methods" do
    
    subject { Repo }
    
    describe ".find" do      
      it "returns a repo object" do
        subject.stub(:update_or_create_bare_repo) do
          `git init --bare #{@test_repo_location}`
          @test_repo_location
        end
        repo = subject.find(@test_repo_url)
        repo.class.should == Repo
        FileUtils.rm_rf @test_repo_location
      end
    end


  end
end
