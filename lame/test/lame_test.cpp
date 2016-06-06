// LAME test program
//
// Copyright (c) 2010 Robert Hegemann
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU Library General Public
// License along with this library; if not, write to the
// Free Software Foundation, Inc., 59 Temple Place - Suite 330,
// Boston, MA 02111-1307, USA.

#include <lame.h>
#include <wchar.h>
#include <stdlib.h>
#include <assert.h>

#include <atomic>
#include <chrono>
#include <memory>
#include <random>

class PcmGenerator
{
  std::unique_ptr<float[]> m_buffer_ch0;
  std::unique_ptr<float[]> m_buffer_ch1;
  int m_size;
  float m_a;
  float m_b;
  std::mt19937 m_generator;
  std::uniform_real_distribution<float> m_distribution;

  template<typename clock, typename output>
  static void push_clock(output& buffer)
  {
    auto now = clock::now().time_since_epoch().count();
    auto now_count = sizeof(now) / sizeof(output::value_type);

    for (decltype(now_count) i = 0; i < now_count; ++i)
    {
      buffer.push_back(static_cast<output::value_type>(now));
      now >>= 8 * sizeof(output::value_type);
    }
  }

  static std::mt19937 create_generator()
  {
    std::vector<std::seed_seq::result_type> buffer;
    std::random_device rd;

    for (auto i = 0; i < std::mt19937::state_size; ++i)
      buffer.push_back(rd());

    // Work-around MinGW's random_device brain damage...
    for (auto i = 0; i < 8; ++i)
      buffer.push_back(rand());

    push_clock<std::chrono::high_resolution_clock>(buffer);
    push_clock<std::chrono::system_clock>(buffer);

    static std::atomic<decltype(buffer)::value_type> counter = 1;

    buffer.push_back(++counter);

    std::seed_seq seed(begin(buffer), end(buffer));

    return std::mt19937(seed);
  }

  float random()
  {
    return m_distribution(m_generator);
  }
public:

  explicit PcmGenerator(int size) : m_generator(create_generator()), m_distribution(-32767, 32768)
  {    
    m_size = size >= 0 ? size : 0;
    m_buffer_ch0 = std::make_unique<float[]>(m_size);
    m_buffer_ch1 = std::make_unique<float[]>(m_size);
    m_a = 0;
    m_b = 0;
    advance(0);
  }

  ~PcmGenerator()
  {
  }

  float const* ch0() const { return m_buffer_ch0.get(); }
  float const* ch1() const { return m_buffer_ch1.get(); }

  void advance( int x ) {
    float a = m_a;
    float b = m_b;
    for (int i = 0; i < m_size; ++i) {
      a += 10;
      if (a > 32768) a = random();
      b -= 10;
      if (b < -32767) b = random();
      m_buffer_ch0[i] = a;
      m_buffer_ch1[i] = b;
    }
    m_a = a;
    m_b = b;
  }
};

class OutFile
{
  FILE* m_file_handle;

public:
  OutFile()
    : m_file_handle(0)
  {}

  explicit OutFile(wchar_t const* filename)
    : m_file_handle(0)
  {
    m_file_handle = _wfopen(filename, L"wbS");
  }
  
  ~OutFile()
  {
    close();
  }

  bool isOpen() const {
    return 0 != m_file_handle;
  }

  void close() {
    if (isOpen()) {
      fclose(m_file_handle);
      m_file_handle = 0;
    }
  }

  int seek(long offset) {
      return fseek(m_file_handle, offset, SEEK_SET);
  }

  size_t write(unsigned char const* data, int n) {
    return fwrite(data, 1, n, m_file_handle);
  }
};

class Lame
{
  lame_t m_gf;
  bool m_init_params_called;
  
  void ensureInitialized() {
    if (isOpen()) {
      if (!m_init_params_called) {
        m_init_params_called = true;
        lame_init_params(m_gf);
      }
    }
  }

public:

  Lame()
    : m_gf( lame_init() ) 
    , m_init_params_called( false )
  {}

  ~Lame()
  {
    close();
  }

  void close() {
    if (isOpen()) {
      lame_close(m_gf);
      m_gf = 0;
    }
  }

  bool isOpen() const {
    return m_gf != 0;
  }

  operator lame_t () {
    return m_gf;
  }
  operator lame_t () const {
    return m_gf;
  }

  void setInSamplerate( int rate ) {
    lame_set_in_samplerate(m_gf, rate);
  }

  void setOutSamplerate( int rate ) {
    lame_set_out_samplerate(m_gf, rate);
  }

  void setNumChannels( int num_channel ) {
    lame_set_num_channels(m_gf, num_channel);
  }

  int encode(float const* ch0, float const* ch1, int n_in, unsigned char* out_buffer, int m_out_free) {
    ensureInitialized();
    return lame_encode_buffer_float(m_gf, ch0, ch1, n_in, out_buffer, m_out_free);
  }

  int flush(unsigned char* out_buffer, int m_out_free) {
    ensureInitialized();
    return lame_encode_flush(m_gf, out_buffer, m_out_free);
  }

  int getLameTag(unsigned char* out_buffer, int m_out_free) {
    ensureInitialized();
    return lame_get_lametag_frame(m_gf, out_buffer, m_out_free);
  }

};

class OutBuffer
{
  std::unique_ptr<unsigned char[]> m_data;
  int m_size;
  int m_used;

public:
  
  OutBuffer()
  {
    m_size = 1000 * 1000;
    m_data = std::make_unique<unsigned char[]>(m_size);
    m_used = 0;
  }

  void advance( int i ) {
    assert(m_used + i <= m_size);
    m_used += i;
  }

  int used() const {
    return m_used;
  }

  int unused() const {
    return m_size - m_used;
  }

  void reset() {
      m_used = 0;
  }

  unsigned char* current() { return m_data.get() + m_used; }
  unsigned char* begin()   { return m_data.get(); }
};

static void flushBuffer(Lame& lame, OutFile& mp3_stream, OutBuffer& mp3_stream_buffer, bool& first_write)
{
  if (first_write) {
    first_write = false;

    int lametag_size0 = lame.getLameTag(0, 0);
    wprintf(L"lametag_size0=%d\n", lametag_size0);

    mp3_stream.seek(lametag_size0);
  }

  mp3_stream.write(mp3_stream_buffer.begin(), mp3_stream_buffer.used());
  mp3_stream_buffer.reset();
}

void generateFile(wchar_t const* filename, size_t n)
{
  int const chunk = 1152;
  PcmGenerator src(chunk);

  OutFile mp3_stream( filename );
  if (!mp3_stream.isOpen()) return;

  Lame lame;
  if (!lame.isOpen()) return;

  OutBuffer mp3_stream_buffer;
  int rc = 0;

  lame.setInSamplerate(44100);
  lame.setOutSamplerate(44100);
  lame.setNumChannels(2);

  bool first_write = true;

  while (n > 0) {
    int const m = n < chunk ? n : chunk;
    if ( n < chunk ) n = 0; else n -= chunk;

    if (mp3_stream_buffer.unused() < 3072)
      flushBuffer(lame, mp3_stream, mp3_stream_buffer, first_write);

    rc = lame.encode(src.ch0(), src.ch1(), m, mp3_stream_buffer.current(), mp3_stream_buffer.unused());
    wprintf(L"rc=%d %d %d\n",rc,mp3_stream_buffer.used(),mp3_stream_buffer.unused());
    if (rc < 0) return;
    mp3_stream_buffer.advance( rc );
    src.advance(m);
  }

  if (mp3_stream_buffer.unused() < 16 * 1024)
    flushBuffer(lame, mp3_stream, mp3_stream_buffer, first_write);

  rc = lame.flush(mp3_stream_buffer.current(), mp3_stream_buffer.unused());
  wprintf(L"flush rc=%d\n",rc);
  if (rc < 0) return;

  mp3_stream_buffer.advance( rc );

  if (mp3_stream_buffer.used() > 0)
    flushBuffer(lame, mp3_stream, mp3_stream_buffer, first_write);

  int lametag_size = lame.getLameTag(0,0);
  wprintf(L"lametag_size=%d\n",lametag_size);

  rc = lame.getLameTag(mp3_stream_buffer.begin(), lametag_size);
  wprintf(L"rc=%d\n",rc);
  if (rc < 0) return;

  mp3_stream_buffer.advance(rc);

  mp3_stream.seek(0);

  // Clobber the start of the file with the lametag. (?)
  mp3_stream.write(mp3_stream_buffer.begin(), mp3_stream_buffer.used());

  lame.close();
}

int wmain(int argc, wchar_t** argv)
{
  if (argc != 3) {
    wprintf(L"usage: %ws <filename> <number pcm samples>\n", argv[0]);
    return -1;
  }
  wprintf(L"open file %ws\n", argv[1]);
  int n = _wtoi(argv[2]);
  wprintf(L"synthesize %d samples long mp3 file\n",n);
  generateFile(argv[1], n);
  return 0;
}
