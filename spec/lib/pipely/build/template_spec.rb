require 'pipely/build/template'

describe Pipely::Build::Template do
  let(:source) { "some test json <%= foo %>" }

  subject { described_class.new(source) }

  context 'given some configuration' do
    let(:foo) { 'asdfgwrytqfadfa' }
    let(:expected_json) { "some test json #{foo}" }

    before do
      subject.apply_config({ foo: foo })
    end

    its(:to_json) { should eq(expected_json) }
  end

  describe "#streaming_hadoop_step(options)" do
    let(:s3_path_builder) {
      Pipely::Build::S3PathBuilder.new(
        logs: 'log-bucket',
        steps: 'step-bucket',
        assets: 'asset-bucket',
        prefix: 'run-prefix'
      )
    }

    before do
      subject.apply_config(s3_path_builder.to_hash)
    end

    it "builds a streaming hadoop step" do
      step = subject.streaming_hadoop_step(
        :input => '/input_dir/',
        :output => '/output_dir/',
        :mapper => '/mapper.rb',
        :reducer => '/reducer.rb'
      )

      expect(step).to eq("/home/hadoop/contrib/streaming/hadoop-streaming.jar,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir/,-output,s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/output_dir/,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,s3n://step-bucket/run-prefix/reducer.rb")
    end

    context "given an array of inputs" do
      it 'points to the IdentityReducer correctly (not as an S3 URL)' do
        step = subject.streaming_hadoop_step(
          :input => ['/input_dir/', '/input_dir2/'],
          :output => '/output_dir/',
          :mapper => '/mapper.rb',
          :reducer => 'org.apache.hadoop.mapred.lib.IdentityReducer'
        )

        expect(step).to eq("/home/hadoop/contrib/streaming/hadoop-streaming.jar,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir/,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir2/,-output,s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/output_dir/,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,org.apache.hadoop.mapred.lib.IdentityReducer")
      end
    end

    context "given a cacheFile" do
      it 'points to the IdentityReducer correctly (not as an S3 URL)' do
        step = subject.streaming_hadoop_step(
          :input => '/input_dir/',
          :output => '/output_dir/',
          :cache_file => '/cache_file#cache_file',
          :mapper => '/mapper.rb',
          :reducer => 'org.apache.hadoop.mapred.lib.IdentityReducer'
        )

        expect(step).to eq("/home/hadoop/contrib/streaming/hadoop-streaming.jar,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir/,-output,s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/output_dir/,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,org.apache.hadoop.mapred.lib.IdentityReducer,-cacheFile,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/cache_file#cache_file")
      end
    end

    context "given the IdentityReducer" do
      it 'points to the IdentityReducer correctly (not as an S3 URL)' do
        step = subject.streaming_hadoop_step(
          :input => '/input_dir/',
          :output => '/output_dir/',
          :mapper => '/mapper.rb',
          :reducer => 'org.apache.hadoop.mapred.lib.IdentityReducer'
        )

        expect(step).to eq("/home/hadoop/contrib/streaming/hadoop-streaming.jar,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir/,-output,s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/output_dir/,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,org.apache.hadoop.mapred.lib.IdentityReducer")
      end
    end

    context "given jar files" do
      it 'loads the file correctly' do
        step = subject.streaming_hadoop_step(
          :input => '/input_dir/',
          :output => '/output_dir/',
          :mapper => '/mapper.rb',
          :reducer => 'org.apache.hadoop.mapred.lib.IdentityReducer',
          :lib_jars => [ 'filter.jar', 'filter2.jar' ],
        )

        expect(step).to eq("/home/hadoop/contrib/streaming/hadoop-streaming.jar,-libjars,filter.jar,-libjars,filter2.jar,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir/,-output,s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/output_dir/,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,org.apache.hadoop.mapred.lib.IdentityReducer")
      end
    end

    context "given variables" do
      it 'defines them correctly' do
        step = subject.streaming_hadoop_step(
          :input => '/input_dir/',
          :output => '/output_dir/',
          :mapper => '/mapper.rb',
          :reducer => 'org.apache.hadoop.mapred.lib.IdentityReducer',
          :defs => {'name' => 'value'}
        )

        expect(step).to eq("/home/hadoop/contrib/streaming/hadoop-streaming.jar,-D,name=value,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir/,-output,s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/output_dir/,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,org.apache.hadoop.mapred.lib.IdentityReducer")
      end
    end
  end

end
