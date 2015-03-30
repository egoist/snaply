config = module.exports = 
  env: 'production',
  port: 2378,
  site: 
    name: 'Snaply',
    name_zh: 'Snaply',
    description: 'share text with a snap'
  development:
    github:
      key: process.env.SNAP_GITHUB_DEV_KEY
      secret: process.env.SNAP_GITHUB_DEV_SECRET
      url: process.env.SNAP_GITHUB_DEV_URL
  production:
    github: 
      key: process.env.SNAP_GITHUB_PRO_KEY
      secret: process.env.SNAP_GITHUB_PRO_SECRET
      url: process.env.SNAP_GITHUB_PRO_URL
  
