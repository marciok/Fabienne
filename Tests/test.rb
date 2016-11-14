require "test/unit"

Dir.chdir("../")
system "set -o pipefail && xcodebuild test -scheme Fabienne | xcpretty -t"  or raise "INTERNAL TESTS FAILED"

result = `xcodebuild -configuration Release BUILD_DIR=$PWD/build/`
result = `./build/Release/Fabienne --file ./Tests/input_tests.fab`
$results = result.split(" ")

class IntegrationTestsFromFile < Test::Unit::TestCase
  def test_1
    assert $results[0] == "36"
  end

  def test_2
    assert $results[1] == "4"
  end

  def test_3
    assert $results[2] == "10"
  end

  def test_4
    assert $results[3] == "31"
  end

  def test_ext_predicated
    assert $results[4] == "0"
  end

  def test_fibonacci
    assert $results[5] == "55"
  end

  def test_sum
    assert $results[6] == "18"
  end

  def test_loop
    assert $results[7] == "d"
    assert $results[8] == "d"
    assert $results[9] == "d"
    assert $results[10] == "0"
  end
end

