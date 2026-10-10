-- php_cs_fixer
-- 忽略任何环境要求
-- 这包括缺少 PHP 扩展、不支持的 PHP 版本或使用 HHVM 等要求
-- 使用时执行可能不稳定。
vim.env["PHP_CS_FIXER_IGNORE_ENV"] = 1
