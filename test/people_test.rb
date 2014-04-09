# encoding: UTF-8

require 'test_helper'

describe People::NameParser do

  shared_examples "a parseable name" do |name, surname, first_initial, given_name|
    context name do
      it 'is parsed' do
        n = People::NameParser.new(case_mode: 'upper').parse(name)
        n.should_not be_nil
        n[:last].should == surname.upcase
        n[:first][0].should == first_initial.upcase
        n[:first].should == given_name.upcase if n[:first].length > 2
      end
    end
  end

  [
    "Alan Turing",
    "A. Turing",
    "A Turing",
    "A.M. Turing",
    "AM Turing",
    "Turing, Alan",
    "Turing, A",
    "Turing, A.",
    "Turing, AM",
    "Turing, A.M.",
    "Alan Mathison Turing",
    "Turing, Alan Mathison",
    "A Turing, Sr.",
    "Alan Turing, Sr",
    "Alan Mathison Turing, Sr",
    "Dr. Alan Turing",
    "Doctor Alan Turing",
    "Dr Alan M Turing",
    "Dr. Alan M. Turing Sr.",
    "Dr. Alan M. Turing, Sr.",
    "DR ALAN TURING",
    "DR A TURING, SR"
  ].each do |name|
    it_should_behave_like "a parseable name", name, "Turing", "A", "Alan"
  end

  [
    "Ignacio De La Fuente Jr.",
    "Ignacio Rafeel De La Fuente Jr.",
    "De La Fuente, Ignacio",
  ].each do |name|
    it_should_behave_like "a parseable name", name, "De La Fuente", "I", "Ignacio"
  end

  [
    "André van der Hoek",
    "Van Der Hoek, André",
  ].each do |name|
    it_should_behave_like "a parseable name", name, "van der Hoek", "A", "André"
  end

  [
    "DR AC DA SILVA",
    "DR. A.C. DA SILVA",
    "Dr. Alfonso César da Silva",
  ].each do |name|
    it_should_behave_like "a parseable name", name, "DA SILVA", "A", "Alfonso"
  end

  [
    "J.L. D'ANGELO",
    "D'ANGELO, JL",
    "John Lewis D'Angelo",
  ].each do |name|
    it_should_behave_like "a parseable name", name, "D'Angelo", "J", "John"
  end


  it_should_behave_like "a parseable name", "Lee Shi Tian", "Tian", "L", "Lee"
  it_should_behave_like "a parseable name", "Tzu-Ching Kuo", "Kuo", "T", "Tzu-Ching"

  [
    "A M T Smythe",
    "A.M.T. Smythe",
    "Andrew M T Smythe",
    "Smythe, Andrew M.T.",
  ].each do |name|
    it_should_behave_like "a parseable name", name, "Smythe", "A", "Andrew"
  end

end
