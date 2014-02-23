# Shared examples to be used by projects that use pipely.
#

shared_examples "a renderable template" do |environment, config|
  let(:rendered_json) {
    Pipely::Build.build_definition(
      subject,
      environment,
      config
    ).to_json
  }

  it "renders without error" do
    expect(rendered_json).to be
  end

  it "produces valid JSON" do
    expect(JSON.parse(rendered_json)).to be
  end

  it "does not contain objects with duplicate ids" do
    objects = JSON.parse(rendered_json)['objects']
    distinct_ids = objects.map{|h| h['id']}.uniq.compact

    expect(objects.count).to eq(distinct_ids.count)
  end
end
