import globals from 'globals'
import pluginJs from '@eslint/js'
import tseslint from 'typescript-eslint'
import eslintPluginPrettierRecommended from 'eslint-plugin-prettier/recommended'

export default [
  { ignores: ['@girs/**'] }, // This should be a separate first item in the array
  { files: ['**/*.{js,mjs,cjs,ts,jsx,tsx}'] },
  { languageOptions: { globals: globals.browser } },
  pluginJs.configs.recommended,
  ...tseslint.configs.recommended,
  eslintPluginPrettierRecommended,
  {
    rules: {
      '@typescript-eslint/no-unused-vars': 0,
      '@typescript-eslint/no-explicit-any': 0,
      'prettier/prettier': [
        'error',
        {
          tabWidth: 2,
          endOfLine: 'lf',
          semi: false,
          printWidth: 100,
          singleQuote: true,
          trailingComma: 'all',
          bracketSpacing: true,
          jsxBracketSameLine: false,
          arrowParens: 'always',
          singleAttributePerLine: true,
        },
      ],
    },
  },
]
