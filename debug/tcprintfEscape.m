function str = tcprintfEscape(str)
    str = strrep(strrep(str, '{', '\{'), '}', '\}');
end

