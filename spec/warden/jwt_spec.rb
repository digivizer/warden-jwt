require 'spec_helper'

describe Warden::JWT do
  it 'has a version number' do
    expect(Warden::JWT::VERSION).not_to be nil
  end
end
