class Cppzmq < Formula
  desc "High-level C++ binding for ZeroMQ"
  homepage "https://github.com/zeromq/cppzmq"
  url "https://github.com/zeromq/cppzmq.git"
  version "0.0.0-brew"

  depends_on "zeromq"

  def install
    include.install "zmq.hpp"
  end
end
