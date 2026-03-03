export default { 
  extends: ['@commitlint/config-conventional'], 
  rules: {
      'body-max-line-length': [1, 'always', 250],
      'footer-max-line-length': [1, 'always', 150]    } 
}