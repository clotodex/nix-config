{
  writeShellApplication,
  grim,
  slurp,
  libnotify,
  wl-clipboard,
  yq,
  zbar,
}:
writeShellApplication {
  name = "screenshot-area-scan-qr";
  runtimeInputs = [
    grim
    slurp
    libnotify
    wl-clipboard
    yq
    zbar
  ];
  text = ''
    umask 077

    TMPFILE=$(mktemp --suffix=.png)
    XMLFILE=$(mktemp --suffix=.xml)
    trap 'rm -f "$TMPFILE" "$XMLFILE"' EXIT

    GEOM=$(slurp) || exit 0
    grim -g "$GEOM" "$TMPFILE"

    set +e
    zbarimg -q --xml "$TMPFILE" > "$XMLFILE"
    rc=$?
    set -e

    case "$rc" in
      0)
        N=$(xq -r '.barcodes.source.index.symbol | if type == "array" then length else 1 end' < "$XMLFILE")
        DATA=$(xq -r '.barcodes.source.index.symbol | if type == "array" then .[0].data else .data end' < "$XMLFILE")
        for ((i=1;i<N;++i)); do
          DATA="$DATA"$'\n'"---"$'\n'"$(xq -r ".barcodes.source.index.symbol[$i].data" < "$XMLFILE")"
        done
        wl-copy <<< "$DATA"
        notify-send \
          "🔍 QR Code scan" "✅ $N codes detected\n📋 copied ''${#DATA} bytes" \
          --hint="string:image-path:"${./assets}/qr-scan.png \
          || true
        ;;
      4)
        notify-send \
          "🔍 QR Code scan" "❌ 0 codes detected" \
          --hint="string:image-path:"${./assets}/qr-scan.png \
          || true
        ;;
      *)
        notify-send \
          "🔍 QR Code scan" "❌ Error while processing image: zbarimg exited with code $rc" \
          --hint="string:image-path:"${./assets}/qr-scan.png \
          || true
        ;;
    esac
  '';
}
