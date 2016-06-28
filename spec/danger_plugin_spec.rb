require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Prose do
    it 'is a plugin' do
      expect(Danger::DangerSwiftLint < Danger::Plugin).to be_truthy
    end
    
    # describe 'with Dangerfile' do
    #   before do
    #     @dangerfile = testing_dangerfile
    #     @prose = testing_dangerfile.prose
    #   end

    #   it "handles proselint not being installed" do
    #     allow(@prose).to receive(:`).with("which proselint").and_return("")
    #     expect(@prose.proselint_installed?).to be_falsy
    #   end

    #   it "handles proselint being installed" do
    #     allow(@prose).to receive(:`).with("which proselint").and_return("/bin/thing/proselint")
    #     expect(@prose.proselint_installed?).to be_truthy
    #   end

    #   describe :lint_files do
    #     it "handles a known JSON report from proselint" do
    #       # So it doesn't try to install on your computer
    #       allow(@prose).to receive(:`).with("which proselint").and_return("/bin/thing/proselint")

    #       # Proselint returns JSON data, which is nice 👍
    #       errors = '[{"start": 1441, "replacements": null, "end": 1445, "severity": "warning", "extent": 4, "column": 1, "message": "!!! is hyperbolic.", "line": 46, "check": "hyperbolic.misc"}]'
    #       proselint_response = '{"status" : "success", "data" : { "errors" : ' + errors + '}}'

    #       # This is where we generate our JSON
    #       allow(@prose).to receive(:`).with("proselint spec/fixtures/blog_post.md --json").and_return(proselint_response)

    #       # it's worth noting - you can call anything on your plugin that a Dangerfile responds to
    #       # The request source's PR JSON typically looks like
    #       # https://raw.githubusercontent.com/danger/danger/bffc246a11dac883d76fc6636319bd6c2acd58a3/spec/fixtures/pr_response.json 
    #       @prose.env.request_source.pr_json = { "head" => { "ref" => "my_fake_branch" }}

    #       # Do it
    #       @prose.lint_files("spec/fixtures/*.md")

    #       output = @prose.status_report[:markdowns].first
          
    #       # A title
    #       expect(output).to include("Proselint found issues")
    #       # A warning
    #       expect(output).to include("!!! is hyperbolic. | warning")
    #       # A link to the file inside the fixtures dir
    #       expect(output).to include("[spec/fixtures/blog_post.md](/artsy/eigen/tree/my_fake_branch/spec/fixtures/blog_post.md)")
    #     end
    #   end
    # end
  end
end
