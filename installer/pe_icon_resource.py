"""Inserts RT_ICON / RT_GROUP_ICON resources into the tested GUI launcher stub.
The appended WPF/patch payload is handled separately by build_wpf_installer.py.
"""
import io
import struct
from pathlib import Path

def align(n,a): return (n+a-1)//a*a

def icon_items(ico_bytes):
    reserved,typ,count=struct.unpack_from('<HHH',ico_bytes)
    assert reserved==0 and typ==1 and count>0
    items=[]
    for i in range(count):
        width,height,palette,reserved,planes,bpp,size,ofs=struct.unpack_from('<BBBBHHII',ico_bytes,6+i*16)
        assert ofs+size<=len(ico_bytes)
        items.append((width,height,palette,planes,bpp,ico_bytes[ofs:ofs+size]))
    return items

def make_resources(ico_bytes, base_rva):
    icons=icon_items(ico_bytes)
    n=len(icons)
    groups=io.BytesIO()
    groups.write(struct.pack('<HHH',0,1,n))
    for i,(w,h,c,p,b,bits) in enumerate(icons,1):
        groups.write(struct.pack('<BBBBHHIH',w,h,c,0,p,b,len(bits),i))
    grp_data=groups.getvalue()
    buf=bytearray()
    def alloc(size,alignment=4):
        pad=align(len(buf),alignment)-len(buf)
        buf.extend(b'\0'*pad)
        off=len(buf)
        buf.extend(b'\0'*size)
        return off
    def dir_header(count):
        off=alloc(16+8*count)
        struct.pack_into('<HH',buf,off+12,0,count)
        return off
    root=dir_header(2)
    typed_icon=dir_header(n)
    typed_group=dir_header(1)
    lang_icons=[dir_header(1) for _ in icons]
    lang_group=dir_header(1)
    data_icons=[alloc(16) for _ in icons]
    data_group=alloc(16)
    blobs=[alloc(len(it[-1])) for it in icons]
    blob_group=alloc(len(grp_data))
    for i,item in enumerate(icons):buf[blobs[i]:blobs[i]+len(item[-1])]=item[-1]
    buf[blob_group:blob_group+len(grp_data)]=grp_data
    # RT_ICON (3), RT_GROUP_ICON (14)
    struct.pack_into('<II',buf,root+16,3,typed_icon|0x80000000)
    struct.pack_into('<II',buf,root+24,14,typed_group|0x80000000)
    for idx in range(n):
        struct.pack_into('<II',buf,typed_icon+16+8*idx,idx+1,lang_icons[idx]|0x80000000)
        struct.pack_into('<II',buf,lang_icons[idx]+16,0x409,data_icons[idx])
        struct.pack_into('<IIII',buf,data_icons[idx],base_rva+blobs[idx],len(icons[idx][-1]),0,0)
    struct.pack_into('<II',buf,typed_group+16,1,lang_group|0x80000000)
    struct.pack_into('<II',buf,lang_group+16,0x409,data_group)
    struct.pack_into('<IIII',buf,data_group,base_rva+blob_group,len(grp_data),0,0)
    return bytes(buf)

def stamp(stub:bytes,ico:bytes)->bytes:
    assert stub[:2]==b'MZ'
    pe=struct.unpack_from('<I',stub,0x3c)[0]
    assert stub[pe:pe+4]==b'PE\0\0'
    count=struct.unpack_from('<H',stub,pe+6)[0]
    optsize=struct.unpack_from('<H',stub,pe+20)[0]
    opt=pe+24
    assert struct.unpack_from('<H',stub,opt)[0]==0x20b
    sectionalign=struct.unpack_from('<I',stub,opt+32)[0]
    filealign=struct.unpack_from('<I',stub,opt+36)[0]
    header_size=struct.unpack_from('<I',stub,opt+60)[0]
    sec=opt+optsize
    assert header_size>=(sec+40*(count+1))
    existing=[]
    for i in range(count):
        row=sec+i*40
        virtual_size,rva,rawsize,rawptr=struct.unpack_from('<IIII',stub,row+8)
        existing.append((rva,virtual_size,rawptr,rawsize))
    newrva=align(max(r+align(max(virt,raw),sectionalign) for r,virt,_,raw in existing),sectionalign)
    newraw=align(len(stub),filealign)
    rsrc=make_resources(ico,newrva)
    rsrc_size=align(len(rsrc),filealign)
    output=bytearray(stub[:newraw])
    output.extend(rsrc)
    output.extend(b'\0'*(rsrc_size-len(rsrc)))
    struct.pack_into('<H',output,pe+6,count+1)
    struct.pack_into('<I',output,opt+56,align(newrva+len(rsrc),sectionalign))
    # PE32+ DataDirectory[2] resource table
    struct.pack_into('<II',output,opt+112+2*8,newrva,len(rsrc))
    newsec=sec+count*40
    output[newsec:newsec+8]=b'.rsrc\0\0\0'
    struct.pack_into('<IIIIIIHHI',output,newsec+8,len(rsrc),newrva,rsrc_size,newraw,0,0,0,0,0x40000040)
    # Skip updating checksum as unsiged PE does not require it; avoid setting stale value.
    struct.pack_into('<I',output,opt+64,0)
    assert len(output)==newraw+rsrc_size
    return bytes(output)

if __name__ == '__main__':
    import sys
    inp=Path(sys.argv[1]); ico=Path(sys.argv[2]); output=Path(sys.argv[3]); output.write_bytes(stamp(inp.read_bytes(),ico.read_bytes()));print(output)
