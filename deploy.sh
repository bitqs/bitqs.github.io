#!/usr/bin/env bash
# wanderen.ai 安全部署 —— 绝不 `wrangler pages deploy .`(会把私有 book_src/ 传上公网!)
# 做法:白名单拷贝公开文件到纯净 staging,再直传 production。
# wanderen 是 direct-upload Pages(Git Provider=No),git push 不会自动部署,必须跑这个。
set -euo pipefail
cd "$(dirname "$0")"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# 白名单:只有这些进公网。新增公开目录时往这里加。
cp -R index.html wanderen-mark.svg book book2 learn value digests "$STAGE"/

# 安全断言:staging 里出现 book_src 就中止
if [ -e "$STAGE/book_src" ]; then
  echo "ABORT: book_src 出现在 staging,拒绝部署(防私有手稿泄露)" >&2
  exit 1
fi

echo "部署纯净 staging → wanderen production ..."
npx wrangler pages deploy "$STAGE" --project-name=wanderen --branch main
