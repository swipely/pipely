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
    before do
      # emulate applying config from S3PathBuilder, as done in Definition#to_json
      subject.apply_config({
        s3_log_prefix: "s3://log-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}",
        s3_step_prefix: "s3://step-bucket/run-prefix",
        s3n_step_prefix: "s3n://step-bucket/run-prefix",
        s3_asset_prefix: "s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}",
        s3n_asset_prefix: "s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}",
        s3_shared_asset_prefix: "s3://asset-bucket/run-prefix/shared/\#{format(@scheduledStartTime,'YYYY-MM-dd')}",
        bucket_relative_s3_asset_prefix: "run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}",
      })
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

    context "given an outputformat" do
      it 'points to the outputformat class (not as an S3 URL)' do
        step = subject.streaming_hadoop_step(
          :input => '/input_dir/',
          :output => '/output_dir/',
          :outputformat => 'com.swipely.foo.outputformat',
          :mapper => '/mapper.rb',
          :reducer => 'org.apache.hadoop.mapred.lib.IdentityReducer'
        )

        expect(step).to eq("/home/hadoop/contrib/streaming/hadoop-streaming.jar,-input,s3n://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/input_dir/,-output,s3://asset-bucket/run-prefix/\#{format(@scheduledStartTime,'YYYY-MM-dd_HHmmss')}/output_dir/,-outputformat,com.swipely.foo.outputformat,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,org.apache.hadoop.mapred.lib.IdentityReducer")
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
          :defs => {'mapred.text.key.partitioner.options' => '-k1,1'}
        )

        expect(step).to eq('/home/hadoop/contrib/streaming/hadoop-streaming.jar,-D,mapred.text.key.partitioner.options=-k1\\,1,-input,s3n://asset-bucket/run-prefix/#{format(@scheduledStartTime,\'YYYY-MM-dd_HHmmss\')}/input_dir/,-output,s3://asset-bucket/run-prefix/#{format(@scheduledStartTime,\'YYYY-MM-dd_HHmmss\')}/output_dir/,-mapper,s3n://step-bucket/run-prefix/mapper.rb,-reducer,org.apache.hadoop.mapred.lib.IdentityReducer')
      end
    end
  end

end
