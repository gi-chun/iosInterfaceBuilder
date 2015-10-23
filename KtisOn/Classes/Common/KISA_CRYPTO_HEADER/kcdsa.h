/*!
 * \file kcdsa.h
 * \brief KCDSA 전자서명 알고리즘 (관련표준 : TTAS.KO-12.001/R1 - 부가형 전자서명 방식 표준 - 제 2 부 : 인증서 기반 전자서명 알고리즘)
 * \author 
 * Copyright (c) 2010 by \<KISA\>
 */

#ifndef KCDSA_H
#define KCDSA_H

#include <kbi.h>
#include <has160.h>

#define KCDSA_SIGN				1		/*!< KCDSA 서명 생성*/
#define KCDSA_VERIFY			0		/*!< KCDSA 서명 검증*/	

#ifdef  __cplusplus
extern "C" {
#endif
	
	/*!
	 * \brief
	 * KCDSA 지원 구조체
	 */
	typedef struct kcdsa_structure	{
		KISA_HAS160 d_unit;					/*!< KCDSA 내부 Digest 알고리즘 구조체*/
		BI p;								/*!< 도메인 변수 p*/
		BI q;								/*!< 도메인 변수 q*/
		BI g;								/*!< 도메인 변수, 생성자 g*/
		BI x;								/*!< 사용자 비밀키 x*/
		BI y;								/*!< 사용자 공개키 y*/
		BI z;								/*!< 공개키 y의 하위 l비트*/
		int is_private;						/*!< KCDSA 알고리즘 서명*/
	}KISA_KCDSA;

	/*!
	 * \brief
	 * KCDSA 전자서명 알고리즘 구동을 위한 내부 연산 엔진 초기화
	 * 
	 * \param kcdsa
	 * KCDSA 전자서명 알고리즘 구조체
	 * 
	 * \param seed
	 * 내부 랜덤 엔진 초기화를 위한 랜덤 정수 입력
	 * 
	 * \remarks
	 * 서명 알고리즘의 정상적인 동작을 위해서 서명 생성 및 검증 절차 수행 전에 반드시 호출
	 */
	void KISA_KCDSA_ENGINE_start(KISA_KCDSA *kcdsa, int seed);
	
	/*!
	 * \brief
	 * KCDSA 내부 엔진 메모리 반환을 위한 내부 연산 엔진 종료
	 * 
	 * \param kcdsa
	 * KCDSA 전자서명 알고리즘 구조체
	 * 
	 * \remarks
	 * 내부적으로 사용된 정수 연산 엔진의 메모리를 해지
	 * 
	 */
	void KISA_KCDSA_ENGINE_close(KISA_KCDSA *kcdsa);
	
	/*!
	 * \brief
	 * KCDSA 전자서명 알고리즘에 도메인 변수 및 개인키/공개키 페어 설정
	 * 
	 * \param kcdsa
	 * KCDSA 전자서명 알고리즘 구조체
	 * 
	 * \param p
	 * KCDSA 도메인 변수 p
	 * 
	 * \param p_len
	 * 도메인 변수 p를 담은 버퍼의 길이
	 * 
	 * \param q
	 * KCDSA 도메인 변수 q
	 * 
	 * \param q_len
	 * 도메인 변수 q를 담은 버퍼의 길이
	 * 
	 * \param g
	 * KCDSA 도메인 변수, 생성자 g 
	 * 
	 * \param g_len
	 * 도메인 변수 g를 담은 버퍼의 길이
	 * 
	 * \param key
	 * 전자서명 생성을 위한 개인키 혹은 검증을 위한 공개키를 입력. 개인키를 입력하면 내부적으로 공개키를 생성. 도메인 변수만 설정할 경우 NULL을 입력
	 * 
	 * \param key_len
	 * 입력한 키를 담은 버퍼의 길이. 키가 NULL일 경우 0을 입력
	 * 
	 * \param priv
	 * -# 입력한 키가 서명용(개인키)일 경우 KCDSA_SIGN (1)로 지정
	 * -# 입력한 키가 검증용(공개키)일 경우 KCDSA_VERIFY (0)로 지정
	 * 
	 * \returns
	 * 도메인 변수 및 키 설정이 올바르게 완료된 경우 (1) / 올바르지 못한 포인터 및 변수 입력으로 인한 실패 (0)
	 *
	 * \remarks
	 * 모든 도메인 변수는 반드시 입력되어야 하며, 개인키가 입력된 경우 내부적으로 공개키를 자동으로 생성함
	 * 
	 */
	int KISA_KCDSA_set_params(
								KISA_KCDSA *kcdsa,
								const unsigned char* p, int p_len,
								const unsigned char* q, int q_len,
								const unsigned char* g, int g_len,
								const unsigned char* key, int key_len,
								int priv);

	/*!
	 * \brief
	 * KISA_KCDSA 구조체에 사용자 키쌍 x, y를 생성하여 입력
	 * 
	 * \param kcdsa
	 * 키쌍 저장을 위한 구조체
	 * 
	 * \remarks
	 * kcdsa 변수에는 KISA_KCDSA_set_params을 통한 도메인 변수가 반드시 입력되어 있어야 함
	 */
	void KISA_KCDSA_gen_key_pair(KISA_KCDSA* kcdsa);

	/*!
	 * \brief
	 * KCDSA 알고리즘 초기화, KISA_KCDSA_ENGINE_start과정과 도메인 변수 및 사용자 키가 입력되어 있어야 함
	 * 
	 * \param kcdsa
	 * KCDSA 전자서명 알고리즘 구조체
	 * 
	 * \param sign
	 * KCDSA 알고리즘 사용 절차가 서명(KCDSA_SIGN)인지 검증(KCDSA_VERIFY)인지 명시
	 * 
	 * \returns
	 * 알고리즘 초기화 성공 (1) / 올바르지 않은 구조체이거나, kcdsa 변수에 개인키가 입력되지 않았는데 서명으로 초기화 한 경우(0)
	 * 
	 */
	int KISA_KCDSA_init(KISA_KCDSA *kcdsa, int sign);

	/*!
	 * \brief
	 * KCDSA 알고리즘의 서명/검증을 위한 데이터 입력
	 * 
	 * \param kcdsa
	 * KCDSA 전자서명 알고리즘 구조체
	 * 
	 * \param data
	 * KCDSA 전자서명 생성/검증을 원하는 데이터 입력
	 * 
	 * \param dataLen
	 * 입력되는 데이터 포인터의 길이
	 * 
	 * \returns
	 * 데이터 입력 성공(1) / 실패(0)
	 * 
	 * \remarks
	 * 데이터 입력은 여러차례에 걸쳐 나누어 입력 가능 
	 */
	int KISA_KCDSA_msg(KISA_KCDSA *kcdsa, const unsigned char *data, unsigned int dataLen);
	
	
	/*!
	 * \brief
	 * KCDSA 알고리즘 전자서명 생성
	 * 
	 * \param kcdsa
	 * KCDSA 전자서명 알고리즘 구조체
	 * 
	 * \param r
	 * KCDSA 전자서명 쌍 (R,S)중 R이 입력될 버퍼
	 * 
	 * \param rLen
	 * 버퍼에 입력된 R의 실제 길이를 반환
	 * 
	 * \param s
	 * KCDSA 전자서명 쌍 (R,S)중 S가 입력될 버퍼
	 * 
	 * \param sLen
	 * 버퍼에 입력된 S의 실제 길이를 반환
	 * 
	 * \returns
	 * 전자서명 생성 성공 (1) / 실패 (0)
	 * 
	 * \remarks
	 * R이 입력될 버퍼의 크기는 HAS160 알고리즘의 출력길이 이상(20 bytes)이며, S가 입력될 버퍼의 크기는 도메인 변수중 Q의 크기(일반적으로 20 bytes) 이상으로 입력해야 함
	 * 	 
	 */
	int KISA_KCDSA_sign(KISA_KCDSA *kcdsa, unsigned char *r, int *rLen, unsigned char *s, int *sLen);

	/*!
	 * \brief
	 * KCDSA 알고리즘 전자서명 검증
	 * 
	 * \param kcdsa
	 * KCDSA 전자서명 알고리즘 구조체
	 * 
	 * \param r
	 * KCDSA 전자서명 쌍 (R,S)중 R이 입력된 버퍼
	 * 
	 * \param rLen
	 * R의 길이
	 * 
	 * \param s
	 * KCDSA 전자서명 쌍 (R,S)중 S가 입력된 버퍼
	 * 
	 * \param sLen
	 * S의 길이
	 * 
	 * \returns
	 * 전자서명 검증 통과 (1) / 잘못된 전자 서명이거나 검증 실패 (0)
	 * 
	 */
	int KISA_KCDSA_verify(KISA_KCDSA *kcdsa, unsigned char *r, int rLen, unsigned char *s, int sLen);

	/*!
	 * \brief
	 * KISA_KCDSA 구조체 내부에 포함된 도메인 파라미터 데이터, 키페어 추출을 위한 함수
	 * 
	 * \param param
	 * 데이터 추출을 원하는 KISA_KCDSA내부의 BI 구조체 중 하나 지정
	 * 
	 * \param buf
	 * 추출된 데이터가 입력될 버퍼의 포인터 (버퍼의 크기는 도메인 변수 P의 길이보다 크게 할당되어 있어야 한다)
	 * 
	 * \param len
	 * 입력된 버퍼의 길이
	 * 
	 * \returns
	 * 성공 : 실제 버퍼에 입력된 데이터의 길이 / 실패(버퍼의 길이가 짧거나 잘못된 포인터일 때) : 0 
	 * 
	 */	
	int KISA_KCDSA_param_to_bytes(BI param, unsigned char * buf, int len);

#ifdef  __cplusplus
}
#endif

#endif