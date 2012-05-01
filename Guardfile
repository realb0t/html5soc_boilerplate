# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, :wait => 60 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/factories/.+\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  watch(%r{^(app).rb$})                               { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^(views)/(.+)(?:\.slim|\.scss)$})          { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
end

guard 'front', :version => 2, :wait => 10 do
end

# guard 'spork', :rspec_env => { 'RACK_ENV' => 'test' } do
#   watch('app.rb')
#   watch('Gemfile')
#   watch('Gemfile.lock')
#   watch('views/.+(slim|scss)') { :rspec }
#   watch('spec/app_spec.rb') { :rspec }
#   watch('spec/spec_helper.rb') { :rspec }
#   watch(%r{features/support/}) { :cucumber }
# end