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

  it "does not generate SnsAlert subjects that are over 100 characters" do
    objects = JSON.parse(rendered_json)['objects']
    sns_alarms = objects.select{|h| h['type'] == 'SnsAlarm'}

    max_object_id = objects.map{|h| h['id']}.max_by(&:length)
    max_attempt_id = max_object_id +  "_2014-01-01T00:00:00_Attempt=1"

    sns_alarms.each do |h|
      # NOTE: This currently only handles the interpolation we use at Swipely.
      # TODO: Support local evaluation of any valid expression.
      interpolated_subject = h['subject'].sub('#{node.name}', max_attempt_id)
      expect( interpolated_subject ).to have_at_most(100).chars
    end
  end

end
