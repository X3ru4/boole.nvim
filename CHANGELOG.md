# Changelog

## [3.4.3](https://github.com/X3ru4/boole.nvim/compare/v3.4.2...v3.4.3) (2026-08-30)


### Bug Fixes

* correctly handle stop column for increment/decrement word matching ([7b15183](https://github.com/X3ru4/boole.nvim/commit/7b1518301346b7bf30844e4ec4f47c33837c2933))

## [3.4.2](https://github.com/X3ru4/boole.nvim/compare/v3.4.1...v3.4.2) (2026-08-21)


### Bug Fixes

* avoid the loop repeating continuously on the last line ([1878284](https://github.com/X3ru4/boole.nvim/commit/18782841ae99796f1efc22d4030639f41f7b9d91))

## [3.4.1](https://github.com/X3ru4/boole.nvim/compare/v3.4.0...v3.4.1) (2026-08-21)


### Bug Fixes

* **init:** always find the selected text in single-line visual mode ([15f87f8](https://github.com/X3ru4/boole.nvim/commit/15f87f839ba2453dde586ae8013b34d678297c05))

## [3.4.0](https://github.com/X3ru4/boole.nvim/compare/v3.3.0...v3.4.0) (2026-08-18)


### Features

* Supports simple progressive increments and decrements. ([813aaaa](https://github.com/X3ru4/boole.nvim/commit/813aaaa676d61a1cf09be4d3ca3972115a6d2ec2))


### Bug Fixes

* call fallback_default after active direction processing to ensure proper fallback handling. ([93aeed5](https://github.com/X3ru4/boole.nvim/commit/93aeed583b7f6619b11fe4655295c441f3ced685))
* correct warning message for line count limit ([6bd015c](https://github.com/X3ru4/boole.nvim/commit/6bd015ce3c4142ea7f8843b4da186f9c7e3afcb0))
* rename MAXIMUN_LOOP to MAXIMUM_LOOP and adjust usage ([9bb10da](https://github.com/X3ru4/boole.nvim/commit/9bb10da202cbfe91d03d62d2bb725ba7871a56b5))
* skip saving words to `match_words` without `prgs` ([921f31e](https://github.com/X3ru4/boole.nvim/commit/921f31e9a404c1d927b21225408b2421915a377a))

## [3.3.0](https://github.com/X3ru4/boole.nvim/compare/v3.2.0...v3.3.0) (2026-08-17)


### Features

* provide default &lt;C-a&gt;/&lt;C-x&gt; mappings with visual mode and progressive support ([dfb6370](https://github.com/X3ru4/boole.nvim/commit/dfb6370bd2db7cfdb3b243c477d2791612aa860d))
* update documentation to reflect new default g&lt;Ctrl-a&gt;/&lt;Ctrl-x&gt; mappings ([9c81c45](https://github.com/X3ru4/boole.nvim/commit/9c81c456f59a434255d6b86920e60ccddd7fbe45))

## [3.2.0](https://github.com/X3ru4/boole.nvim/compare/v3.1.0...v3.2.0) (2026-08-01)


### Features

* **boole:** add maximun_move option and increase default loop limit ([a0ebf12](https://github.com/X3ru4/boole.nvim/commit/a0ebf122494bab3c1b4991b5db68a5c5a34ea817))
* **boole:** add maximun_move option and increase default loop limit ([091adcc](https://github.com/X3ru4/boole.nvim/commit/091adcc83eba1e7f90af3bb2c672c25f6f1ab7b0))

## [3.1.0](https://github.com/X3ru4/boole.nvim/compare/v3.0.1...v3.1.0) (2026-07-30)


### Features

* black hole register ([#27](https://github.com/X3ru4/boole.nvim/issues/27)) ([cb8adf2](https://github.com/X3ru4/boole.nvim/commit/cb8adf23532f96e1e807ca8e8275c6878380da53))
* black hole register ([#27](https://github.com/X3ru4/boole.nvim/issues/27)) ([b889552](https://github.com/X3ru4/boole.nvim/commit/b889552dd9c7bf48e607533db7d3682c1cf58000))
* **boole:** add boole plugin with cycle generation, presets, and types ([2943c36](https://github.com/X3ru4/boole.nvim/commit/2943c362a4918f1ee52620ea1b4fc00483bc5b28))

## [3.0.1](https://github.com/nat-418/boole.nvim/compare/v3.0.0...v3.0.1) (2023-01-14)


### Bug Fixes

* misc bugfixes ([16836c4](https://github.com/nat-418/boole.nvim/commit/16836c444252295cc984fe831fc6ef4ec186d89b))

## [3.0.0](https://github.com/nat-418/boole.nvim/compare/v2.1.2...v3.0.0) (2022-11-14)


### ⚠ BREAKING CHANGES

* jump to matches correctly

### Features

* add enable/disable ([3bc80ec](https://github.com/nat-418/boole.nvim/commit/3bc80ece8ea74f85665e0184d5853ee583dec534))
* expose generate method ([0348b3e](https://github.com/nat-418/boole.nvim/commit/0348b3eaa5be364a3a8b4e896d81f35a66b5cd21))
* support case insensitive pairs ([93617c4](https://github.com/nat-418/boole.nvim/commit/93617c4bc1f1826c76b17fc952c22ef48fe6d276))


### Bug Fixes

* hard stop at EOL ([cbb9221](https://github.com/nat-418/boole.nvim/commit/cbb9221256db9a76a479760e331294dcf1681264))
* jump to matches correctly ([49a1354](https://github.com/nat-418/boole.nvim/commit/49a1354ef0fd3bc23350cbbf3f8d9e7d11cab077))
* misc. bugs ([a21bef2](https://github.com/nat-418/boole.nvim/commit/a21bef208cf557f512606ba3deaef7bd0fe8bc4b))
* misc. bugs ([9714f67](https://github.com/nat-418/boole.nvim/commit/9714f67c7ec3aea3ba2c9a483ef27153a6ba0e73))
* misc. bugs ([c46279f](https://github.com/nat-418/boole.nvim/commit/c46279fec4f43257fbf54596122927786711d921))
* off by one error / infinite loop ([5515ad9](https://github.com/nat-418/boole.nvim/commit/5515ad95bd751ca4bde10f54f9f01a5669122a54))
* off by one error / infinite loop ([353e9e1](https://github.com/nat-418/boole.nvim/commit/353e9e1dbfe3ed3d5dc4bf1f40cf632188965f53))
