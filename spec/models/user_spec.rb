# encoding: utf-8
require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe User do

  context "использование бонуса" do

    before {
      subject.stub!(:refresh_real_balance!).and_return(true)
    }

    it "бонус может быть использован" do
      subject.real_balance = 5
      subject.bonus_balance = 5
      test = nil
      subject.charge_off_real_and_call!(5) { test = true }
      test.should_not be_nil
    end

    it "бонус не доступен из-за баланса" do
      subject.real_balance = 4
      subject.bonus_balance = 5
      test = nil
      subject.charge_off_real_and_call!(5) { test = true }
      test.should be_nil
    end

    it "бонус не доступен из-за количества" do
      subject.real_balance = 5
      subject.bonus_balance = 4
      test = nil
      subject.charge_off_real_and_call!(5) { test = true }
      test.should be_nil
    end

    it "бонус может быть использован за отправку открытки" do
      test = nil
      subject.charge_off_real_and_call!(1.0) { test = true }
      test.should_not be_nil
    end

  end

end