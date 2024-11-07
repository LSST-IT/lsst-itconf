# frozen_string_literal: true

shared_examples 'lsstcam-dc.cp' do
  it do
    is_expected.to contain_s3daemon__instance('cp-lsstcam').with(
      s3_endpoint_url: 'https://s3.cp.lsst.org',
      port: 15_570,
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9'
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('sdfembs3-lsstcam').with(
      s3_endpoint_url: 'https://sdfembs3.sdf.slac.stanford.edu',
      port: 15_580,
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9'
    )
  end

  it do
    is_expected.to contain_s3daemon__instance('elqui-lsstcam').with(
      s3_endpoint_url: 'https://s3.elqui.cp.lsst.org',
      port: 15_590,
      image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9'
    )
  end
end
