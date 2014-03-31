require 'spec_helper'

describe Shrimple do
  it "automatically finds the executable and renderer" do
    s = Shrimple.new
    expect(File.executable? s.executable).to be true
    expect(File.exists? s.renderer).to be true
  end

  it "can be told the executable and renderer" do
    # these don't need to be real executables since they're never called
    s = Shrimple.new(executable: '/bin/sh', renderer: example_html)
    expect(s.executable).to eq '/bin/sh'
    expect(s.renderer).to eq example_html
  end

  it "dies if executable can't be found" do
    s = Shrimple.new(executable: '/bin/THIS_FILE_DOES.not.Exyst')
    expect { s.render 'http://be.com' }.to raise_exception(/[Nn]o such file.*THIS_FILE_DOES.not.Exyst/)
  end

  it "allows a bunch of different ways to set options" do
    s = Shrimple.new(executable: '/bin/sh', renderer: example_html, background: true)

    s.executable = '/bin/cat'
    s.page.paperSize.orientation = 'landscape'
    s[:page][:settings][:userAgent] = 'webkitalike'
    s.options.page.zoomFactor = 0.25

    expect(Shrimple).to receive(:execute).once do |opts|
      expect(opts.to_hash).to eq(Hashie::Mash.new({
        input: 'infile',
        output: 'outfile',
        executable: '/bin/cat',
        renderer: example_html,
        background: true,
        page: {
          paperSize: { orientation: 'landscape' },
          settings: { userAgent: 'webkitalike' },
          zoomFactor: 0.25
        }
      }).to_hash)
    end

    s.render 'infile', 'outfile'
  end

  it "has a working compact" do
    expect(Shrimple.compact({
      a: nil,
      b: { c: nil },
      d: { e: { f: "", g: 1 } },
      h: false
    })).to eq({
      d: { e: { g: 1 }},
      h: false
    })

    expect(Shrimple.compact({})).to eq({})
  end
end
