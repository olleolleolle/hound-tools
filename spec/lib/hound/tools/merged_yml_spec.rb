require "hound/tools/merged_yml"

require_relative "template_spec"

RSpec.describe Hound::Tools::MergedYml do
  filename = ".hound/.rubocop.yml"

  # it_behaves_like "a template", filename
  specify { expect(subject.filename).to eq(filename) }

  describe "#generate" do
    let(:hound_yml) { instance_double(Hound::Tools::HoundYml) }

    before do
      allow(Hound::Tools::HoundYml).to receive(:new).and_return(hound_yml)
      allow(hound_yml).to receive(:rubocop_filename).and_return(filename)

      allow(IO).to receive(:read).with(".hound/overrides.yml").and_return("foo")
      allow(IO).to receive(:read).with(".rubocop_todo.yml").and_return("bar")
      allow(FileUtils).to receive(:mkpath).with('.hound')

      allow(IO).to receive(:write).with(filename, anything)
    end

    it "regenerates the file" do
      expected = <<-EOS.gsub(/^\s+/,'')
      # This is a file generated by `hound-tools`
      #
      # We don't include .hound/defaults.yml, because Hound has internally
      # loaded them at this point
      #
      # ---------------------------------
      # .hound/overrides.yml
      # ---------------------------------
      foo
      # ---------------------------------
      # .rubocop_todo.yml
      # ---------------------------------
      bar
      EOS
      expect(IO).to receive(:write).with(filename, anything) do |_, data|
        expect(data).to eq(expected)
      end

      subject.generate
    end

    it "prints info about merging" do
      expect($stdout).to receive(:puts).with(/\.hound\/\.rubocop\.yml \(regenerated\)/)
      subject.generate
    end
  end
end
