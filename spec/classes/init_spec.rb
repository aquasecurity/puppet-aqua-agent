require 'spec_helper'
describe 'aquaenforcer' do
  context 'with default values for all parameters' do
    it { should contain_class('aquaenforcer') }
  end
end
